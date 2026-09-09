module Pii
  # Rewrites every encrypted attribute under the current key-derivation digest.
  class ReEncryptor
    BATCH_SIZE = 1_000

    # Resuming starts at that model and processes every later one in full. Each
    # batch logs the arguments to pass back.
    def initialize(resume_model: nil, resume_id: nil, logger: Rails.logger)
      if resume_model.present? && MODEL_NAMES.exclude?(resume_model)
        raise ArgumentError, "#{resume_model} is not one of #{MODEL_NAMES.join(", ")}"
      end

      @resume_model = resume_model.presence
      @resume_id = resume_id.presence && Integer(resume_id)
      @logger = logger
    end

    def call
      pending_models.each { |model| re_encrypt(model) }
    end

    private

    attr_reader :logger, :resume_model, :resume_id

    def pending_models
      names = resume_model ? MODEL_NAMES.drop(MODEL_NAMES.index(resume_model)) : MODEL_NAMES

      names.map(&:constantize)
    end

    def re_encrypt(model)
      converted = 0
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      scope_for(model).find_in_batches(batch_size: BATCH_SIZE) do |records|
        model.transaction { records.each { |record| convert(record) } }
        converted += records.size
        log_progress(model, records.last.id, converted, started_at)
      end

      logger.info("pii:re_encrypt finished #{model.name}: #{converted} rows")
    end

    def scope_for(model)
      return model.all unless model.name == resume_model && resume_id

      model.where(model.primary_key => resume_id..)
    end

    # Two steps, because Rails can read eight of these ten columns and not the
    # other two.
    #
    # support_sha1_for_non_deterministic_encryption gives the non-deterministic
    # columns a SHA-1 previous scheme, so record.encrypt reads them itself and
    # writes them back under the current digest. It cannot give the deterministic
    # ones the same, because Rails only attaches a previous scheme to an attribute
    # whose determinism matches. So their plaintext is recovered here and assigned
    # first, and record.encrypt then finds it already in place rather than
    # attempting a decryption that would raise.
    def convert(record)
      DETERMINISTIC_ATTRIBUTES.fetch(record.class.name, []).each do |attribute|
        record[attribute] = plaintext_for(record, attribute)
      end

      record.encrypt
    rescue ActiveRecord::Encryption::Errors::Base => e
      # The bare error names deserialize and nothing else, which during a
      # maintenance window leaves no way to find the row without bisecting.
      raise e.class, "#{record.class.name}##{record.id}: #{e.message}", e.backtrace
    end

    def plaintext_for(record, attribute)
      raw = record.read_attribute_before_type_cast(attribute)
      return raw if raw.nil?

      readers = readers_for(record.class, attribute)
      begin
        readers[:current].deserialize(raw)
      rescue ActiveRecord::Encryption::Errors::Decryption
        readers[:sha1].deserialize(raw)
      end
    end

    # A reader per digest for one deterministic column. Only User#email and
    # DsiUser#email are deterministic, so this holds two entries.
    #
    # Both pin support_unencrypted_data false rather than inheriting it. When that
    # global is true a failed decryption hands back the raw ciphertext instead of
    # raising, so the current reader would appear to succeed and that ciphertext
    # would be encrypted again as though it were plaintext, with verification then
    # reporting the row readable.
    def readers_for(model, attribute)
      @readers ||= {}
      @readers[[model.name, attribute]] ||= key_providers.transform_values do |key_provider|
        ActiveRecord::Encryption::EncryptedAttributeType.new(
          scheme: ActiveRecord::Encryption::Scheme.new(
            deterministic: true,
            key_provider:,
            support_unencrypted_data: false
          ),
          default: model.columns_hash[attribute.to_s].default
        )
      end
    end

    # The digest in force now, and the one that wrote the rows being converted.
    # Deriving a key is expensive, so both are built once for the whole run.
    #
    # DeterministicKeyProvider takes no key_generator, so the SHA-1 derivation goes
    # through its parent. For a single key the two are equivalent, and
    # deterministic keys cannot be rotated, so there is only ever one.
    def key_providers
      @key_providers ||= begin
        key = ActiveRecord::Encryption.config.deterministic_key
        if key.blank?
          raise ActiveRecord::Encryption::Errors::Configuration,
                "no deterministic encryption key is configured, so SHA-1 ciphertext cannot be read"
        end

        {
          current: ActiveRecord::Encryption::DeterministicKeyProvider.new(key),
          sha1: ActiveRecord::Encryption::DerivedSecretKeyProvider.new(
            key,
            key_generator: ActiveRecord::Encryption::KeyGenerator.new(hash_digest_class: OpenSSL::Digest::SHA1)
          )
        }
      end
    end

    def log_progress(model, last_id, converted, started_at)
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

      logger.info(
        "pii:re_encrypt converted=#{converted} elapsed=#{elapsed.round}s " \
        "rate=#{(converted / [elapsed, 1].max).round}/s " \
        "resume with pii:re_encrypt[#{model.name},#{last_id}]"
      )
    end
  end
end

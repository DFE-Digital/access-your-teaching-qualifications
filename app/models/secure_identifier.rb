class SecureIdentifier
  SECRET_KEY = Rails.application.credentials.secret_key_base.byteslice(0..31)
  CIPHER = 'aes-256-cbc'.freeze

  def self.encode(value)
    raise ArgumentError, "value cannot be nil" if value.nil?
    return value if value.empty?

    cipher = OpenSSL::Cipher.new(CIPHER)
    cipher.encrypt
    cipher.key = SECRET_KEY

    encrypted = cipher.update(value) + cipher.final # rubocop:disable Rails/SaveBang
    Base64.urlsafe_encode64(encrypted).strip
  end

  def self.decode(value)
    raise ArgumentError, "value cannot be nil" if value.nil?
    return value if value.empty?

    decipher = OpenSSL::Cipher.new(CIPHER)
    decipher.decrypt
    decipher.key = SECRET_KEY
  
    begin
      decoded = Base64.urlsafe_decode64(value)
      decipher.update(decoded) + decipher.final # rubocop:disable Rails/SaveBang
    rescue ArgumentError
      value
    end
  end
end
module Qualifications
  module OneLoginUsers
    class NameChangeForm
      include ActiveModel::Model
      include ActiveModel::Validations

      MAX_SIZE = 3.megabytes
      ALLOWED_CONTENT_TYPES = ["image/jpeg", "image/png", "application/pdf"].freeze

      attr_accessor :first_name, :middle_name, :last_name, :evidence, :user

      validates :first_name, presence: true, length: { maximum: 100 }
      validates :middle_name, length: { maximum: 100 }
      validates :last_name, presence: true, length: { maximum: 100 }

      validates :evidence, presence: true

      validate :validate_file_size
      validate :validate_content_type

      def self.initialize_with(name_change:)
        new(
          first_name: name_change.first_name,
          middle_name: name_change.middle_name,
          last_name: name_change.last_name,
          evidence: name_change.evidence,
          user: name_change.user,
        )
      end

      def save
        return false unless valid?

        name_change = user.name_changes.create!(
          first_name:,
          middle_name:,
          last_name:,
        )
        name_change.evidence.attach evidence
        name_change
      end

      def update(name_change)
        return false unless valid?

        name_change.update!(
          first_name:,
          middle_name:,
          last_name:,
        )
        name_change.evidence.attach evidence
        name_change
      end

      private

      def validate_file_size
        if evidence && evidence.size > MAX_SIZE
          errors.add(:evidence, "The selected file must be smaller than 3MB")
        end
      end

      def validate_content_type
        return if evidence.blank?
        return if ALLOWED_CONTENT_TYPES.include?(evidence.content_type) &&
          sniffed_content_type == evidence.content_type

        errors.add(:evidence, "The selected file must be a PDF, JPG, JPEG or PNG")
      end

      def sniffed_content_type
        # Pass only the IO so Marcel determines the type from the file's magic
        # bytes, ignoring the client-supplied filename and Content-Type header
        Marcel::MimeType.for(evidence)
      end
    end
  end
end

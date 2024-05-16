module Qualifications
  module OneLoginUsers
    class DateOfBirthChangeForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :day, :month, :year, :evidence, :user

      validate do |search|
        DayMonthYearValidator.new.validate(search, :date_of_birth)
      end

      validates :evidence, presence: true
      validate :validate_file_size
      validate :validate_content_type

      def date_of_birth
        Date.new(year.to_i, month.to_i, day.to_i)
      rescue StandardError
        InvalidDate.new(day:, month:, year:)
      end

      def save
        return false unless valid?

        date_of_birth_change = user.date_of_birth_changes.create!(date_of_birth:)
        date_of_birth_change.evidence.attach evidence
        date_of_birth_change
      end

      private

      def validate_file_size
        max_size = 3.megabytes
        if evidence && evidence.size > max_size
          errors.add(:evidence, "The selected file must be smaller than 3MB")
        end
      end

      def validate_content_type
        allowed_types = ["image/jpeg", "image/png", "application/pdf"]
        if evidence && !allowed_types.include?(evidence.content_type)
          errors.add(:evidence, "The selected file must be an image or a PDF")
        end
      end
    end
  end
end


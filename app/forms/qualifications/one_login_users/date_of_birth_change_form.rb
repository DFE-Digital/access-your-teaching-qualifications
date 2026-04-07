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

      def self.initialize_with(date_of_birth_change:)
        new(
          day: date_of_birth_change.date_of_birth.day,
          month: date_of_birth_change.date_of_birth.month,
          year: date_of_birth_change.date_of_birth.year,
          evidence: date_of_birth_change.evidence,
          user: date_of_birth_change.user,
        )
      end

      def save
        return false unless valid?

        date_of_birth_change = user.date_of_birth_changes.create!(date_of_birth:)
        date_of_birth_change.evidence.attach evidence
        date_of_birth_change
      end

      def update(date_of_birth_change)
        return false unless valid?

        date_of_birth_change.update!(
          date_of_birth:
        )
        date_of_birth_change.evidence.attach evidence
        date_of_birth_change
      end

      def date_of_birth
        Date.new(year.to_i, month.to_i, day.to_i)
      rescue StandardError
        InvalidDate.new(day:, month:, year:)
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
          errors.add(:evidence, "The selected file must be a PDF, JPG, JPEG or PNG")
        end
      end
    end
  end
end


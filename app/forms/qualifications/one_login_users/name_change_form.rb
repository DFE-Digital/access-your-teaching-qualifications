module Qualifications
  module OneLoginUsers
    class NameChangeForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :first_name, :middle_name, :last_name, :evidence, :user

      validates :first_name, presence: true, length: { maximum: 100 }
      validates :middle_name, length: { maximum: 100 }
      validates :last_name, presence: true, length: { maximum: 100 }

      # TODO: implement evidence validations
      # validates :evidence,
      #   file_size: { less_than: 3.megabytes },
      #   file_content_type: { allow: ['image/jpeg', 'application/pdf'] }

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
    end
  end
end

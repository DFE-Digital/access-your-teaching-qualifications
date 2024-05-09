module Qualifications
  module OneLoginUsers
    class NameChangeForm
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :first_name, :middle_name, :last_name, :evidence

      validates :first_name, presence: true, length: { maximum: 100 }
      validates :middle_name, length: { maximum: 100 }
      validates :last_name, presence: true, length: { maximum: 100 }

      # TODO: implement evidence validations
      # validates :evidence,
      #   file_size: { less_than: 3.megabytes },
      #   file_content_type: { allow: ['image/jpeg', 'application/pdf'] }

      def save
        return false unless valid?


        true
      end
    end
  end
end

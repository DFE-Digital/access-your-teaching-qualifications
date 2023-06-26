module QualificationsApi
  class Certificate
    VALID_TYPES = %i[eyts induction itt mq npq qts].freeze
    attr_reader :user_name, :type, :file_data

    def initialize(user_name, type, file_data)
      @user_name = user_name
      @type = type
      @file_data = file_data
    end

    def file_name
      "#{user_name}_#{type}_certificate.pdf"
    end
  end
end

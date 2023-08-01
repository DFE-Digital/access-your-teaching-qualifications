module QualificationsApi
  class Certificate
    include ActiveModel::Model

    VALID_TYPES = %i[eyts induction itt mq npq qts].freeze
    attr_accessor :name, :type, :file_data

    def file_name
      "#{name}_#{type}_certificate.pdf"
    end
  end
end

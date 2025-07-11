module QualificationsApi
  class Certificate
    include ActiveModel::Model

    VALID_TYPES = %i[eyts induction rtps NPQEL NPQLTD NPQLT NPQH NPQML NPQLL NPQEYL NPQSL NPQLBC NPQSENCO NPQLPM
qts].freeze

    attr_accessor :name, :type, :file_data

    def file_name
      "#{name}_#{type}_certificate.pdf"
    end
  end
end

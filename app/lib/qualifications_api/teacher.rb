module QualificationsApi
  class Teacher
    attr_reader :api_data

    def initialize(api_data)
      @api_data = api_data
    end

    def trn
      api_data.fetch("trn")
    end

    def first_name
      api_data.fetch("firstName")
    end

    def last_name
      api_data.fetch("lastName")
    end

    def qts_date
      api_data.fetch("qtsDate")&.to_date
    end
  end
end

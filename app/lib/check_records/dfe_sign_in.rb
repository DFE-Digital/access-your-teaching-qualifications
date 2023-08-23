require "hosting_environment"

module CheckRecords
  class DfESignIn
    def self.bypass?
      bypass_active? || review_app?
    end

    def self.bypass_active?
      HostingEnvironment.test_environment? && ENV["BYPASS_DSI"] == "true"
    end

    def self.review_app?
      HostingEnvironment.review?
    end
  end
end

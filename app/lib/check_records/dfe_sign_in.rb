require "hosting_environment"

module CheckRecords
  class DfESignIn
    def self.bypass?
      HostingEnvironment.test_environment? && ENV["BYPASS_DSI"] == "true"
    end
  end
end

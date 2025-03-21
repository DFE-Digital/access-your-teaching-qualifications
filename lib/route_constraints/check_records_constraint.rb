module RouteConstraints
  class CheckRecordsConstraint
    def matches?(request)
      # TODO: Update after AKS migration
      request.host.in?(HostingEnvironment.check_records_domain) ||
        request.host.include?("aytq-review-pr") ||
        request.host.include?("check-a-teachers-record-pr-") ||
        request.host.include?("check-a-teachers-record-temp")
    end
  end
end

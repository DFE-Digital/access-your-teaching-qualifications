module RouteConstraints
  class CheckRecordsConstraint
    def matches?(request)
      request.host.in?(HostingEnvironment.check_records_domain) ||
        request.host.include?("aytq-review-pr")
    end
  end
end

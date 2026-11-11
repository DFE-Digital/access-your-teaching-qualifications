module RouteConstraints
  class AccessYourTeachingQualificationsConstraint
    def matches?(request)
      # TODO: Update after AKS migration
      request.host.in?(HostingEnvironment.aytq_domain) ||
      request.host.include?("aytq-review-pr") ||
      request.host.include?("access-your-teaching-qualifications-pr-") ||
      request.host.include?("access-your-teaching-qualifications-temp") ||
      request.host.include?("access-your-teaching-qualifications-test-temp") ||
      request.host.include?("access-your-teaching-qualifications-preprod-temp")
    end
  end
end

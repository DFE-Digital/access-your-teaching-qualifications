module RouteConstraints
  class AccessYourTeachingQualificationsConstraint
    def matches?(request)
      request.host.in?(HostingEnvironment.aytq_domain) || request.host.include?("aytq-review-pr")
    end
  end
end

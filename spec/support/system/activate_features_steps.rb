module ActivateFeaturesSteps
  def given_the_check_service_is_open
    FeatureFlags::FeatureFlag.activate(:check_service_open)
  end

  def given_the_qualifications_service_is_open
    FeatureFlags::FeatureFlag.activate(:qualifications_service_open)
  end

  def given_the_support_service_is_open
    FeatureFlags::FeatureFlag.activate(:support_service_open)
  end

  def given_staff_http_basic_is_active
    FeatureFlags::FeatureFlag.activate(:staff_http_basic_auth)
  end

  alias_method :and_staff_http_basic_is_active, :given_staff_http_basic_is_active
end

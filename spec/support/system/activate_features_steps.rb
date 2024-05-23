module ActivateFeaturesSteps
  def given_the_check_service_is_open
    FeatureFlags::FeatureFlag.activate(:check_service_open)
  end

  def given_the_qualifications_service_is_open
    FeatureFlags::FeatureFlag.activate(:qualifications_service_open)
  end

  def given_the_terms_and_conditions_feature_flag_is_enabled
    FeatureFlags::FeatureFlag.activate(:terms_and_conditions)
  end

  def given_the_support_service_is_open
    FeatureFlags::FeatureFlag.activate(:support_service_open)
  end

  def given_onelogin_authentication_is_active
    FeatureFlags::FeatureFlag.activate(:one_login)
  end
end

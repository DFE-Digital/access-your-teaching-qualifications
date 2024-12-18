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

  def given_onelogin_authentication_is_active
    FeatureFlags::FeatureFlag.activate(:one_login)
  end

  def given_the_trn_search_feature_is_active
    FeatureFlags::FeatureFlag.activate(:trn_search)
  end

  def and_bulk_search_is_enabled
    FeatureFlags::FeatureFlag.activate(:bulk_search)
  end
end

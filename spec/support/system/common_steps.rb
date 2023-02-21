module CommonSteps
  include AuthenticationSteps
  include AuthorizationSteps
  include ActivateFeaturesSteps

  def when_i_visit_the_service
    visit root_path
  end

  def when_i_visit_the_support_interface
    visit support_interface_path
  end
end

module CommonSteps
  include AuthorizationSteps
  include ActivateFeaturesSteps

  def and_event_tracking_is_working
    expect(:web_request).to have_been_enqueued_as_analytics_events
  end

  def when_i_visit_the_service
    visit root_path
  end

  def when_i_visit_the_qualifications_service
    visit qualifications_root_path
  end

  def when_i_visit_the_support_interface
    visit support_interface_path
  end
end

module CommonSteps
  include AuthorizationSteps
  include ActivateFeaturesSteps

  def and_event_tracking_is_working
    expect(:web_request).to have_been_enqueued_as_analytics_events
  end

  # Chrome occasionally stalls acknowledging a mouse click that triggers a
  # download, which surfaces as Ferrum::TimeoutError on the click itself.
  # Triggering the click from JavaScript avoids the CDP input
  # acknowledgement entirely; the download still starts.
  def download_certificate(link_text, filename:)
    link = find_link(link_text)
    page.execute_script("arguments[0].click()", link)
    and_i_wait_for_the_download_to_finish(filename:)
  end

  # Certificate downloads don't navigate or change the DOM, so there is
  # nothing for Capybara to synchronise on: response_headers can still be the
  # previous response's (the HTML page, or an earlier download) until this
  # download's response arrives. Poll for the expected download before
  # asserting on it; on timeout fall through and let the caller's
  # expectations report the actual headers.
  def and_i_wait_for_the_download_to_finish(filename:)
    Timeout.timeout(Capybara.default_max_wait_time * 5) do
      sleep 0.1 until page.response_headers&.dig("content-disposition").to_s.include?(filename)
    end
  rescue Timeout::Error
    nil
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

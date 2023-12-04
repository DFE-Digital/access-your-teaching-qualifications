# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    include DsiAuthenticatable
    include SupportNamespaceable

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("support_service_open") }
    )

    layout "support_layout"

    def current_staff
      @current_staff ||= DsiUser.staff.find(session[:dsi_user_id]) if session[:dsi_user_id]
    end
    helper_method :current_staff

    def find_current_auditor
      current_staff.presence
    end

    def http_basic_authenticate
      valid_credentials = [
        {
          username: ENV.fetch("SUPPORT_USERNAME", "support"),
          password: ENV.fetch("SUPPORT_PASSWORD", "support")
        }
      ]

      authenticate_or_request_with_http_basic do |username, password|
        valid_credentials.include?({ username:, password: })
      end
    end
  end
end

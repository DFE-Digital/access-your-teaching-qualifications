# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    include SupportNamespaceable

    http_basic_authenticate_with(
      name: ENV.fetch("SUPPORT_USERNAME", nil),
      password: ENV.fetch("SUPPORT_PASSWORD", nil),
      unless: -> { FeatureFlags::FeatureFlag.active?("support_service_open") }
    )

    layout "support_layout"

    before_action :authenticate_staff!

    def find_current_auditor
      current_staff.presence
    end
  end
end

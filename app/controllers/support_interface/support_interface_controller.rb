# frozen_string_literal: true
module SupportInterface
  class SupportInterfaceController < ApplicationController
    include SupportNamespaceable

    layout "support_layout"

    before_action :authenticate_staff!

    def find_current_auditor
      current_staff.presence
    end
  end
end

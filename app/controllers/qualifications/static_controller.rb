# frozen_string_literal: true

module Qualifications
  class StaticController < QualificationsInterfaceController
    skip_before_action :authenticate_user!
    skip_before_action :handle_expired_token!

    layout "two_thirds"
  end
end

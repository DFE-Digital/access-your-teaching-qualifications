# frozen_string_literal: true
module Qualifications
  class ErrorsController < QualificationsInterfaceController
    include HttpErrorHandling

    skip_before_action :authenticate_user!
    skip_before_action :handle_expired_token!
  end
end

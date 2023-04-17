module Qualifications
  class StartsController < QualificationsInterfaceController
    skip_before_action :authenticate_user!
    skip_before_action :handle_expired_token!

    def show
    end
  end
end

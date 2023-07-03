class AuthFailuresController < ApplicationController
  def failure
    strategy = request.env["omniauth.error.strategy"].name

    case strategy
    when :identity
      redirect_to qualifications_dashboard_path
    when :dfe
      redirect_to check_records_root_path
    end
  end
end

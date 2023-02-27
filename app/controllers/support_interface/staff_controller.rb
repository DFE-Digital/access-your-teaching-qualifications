class SupportInterface::StaffController < ApplicationController
  def index
    @staff = Staff.all
  end
end

# frozen_string_literal: true

class CheckRecords::NavigationComponent < ViewComponent::Base
  attr_accessor :current_dsi_user

  def initialize(current_dsi_user:)
    super
    @current_dsi_user = current_dsi_user
  end
end

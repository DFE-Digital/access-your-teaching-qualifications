# frozen_string_literal: true

class Qualifications::NavigationComponent < ViewComponent::Base
  attr_accessor :current_user

  def initialize(current_user:)
    super
    @current_user = current_user
  end
end

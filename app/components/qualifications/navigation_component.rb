# frozen_string_literal: true

class Qualifications::NavigationComponent < ApplicationComponent
  attr_accessor :current_user

  def initialize(current_user:)
    super()
    @current_user = current_user
  end
end

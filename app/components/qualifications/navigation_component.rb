# frozen_string_literal: true

class Qualifications::NavigationComponent < ApplicationComponent
  attr_accessor :current_user, :current_session

  def initialize(current_user:, current_session:)
    super()
    @current_user = current_user
    @current_session = current_session
  end
end

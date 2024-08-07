# frozen_string_literal: true

class ActionAtComponent < ViewComponent::Base
  include ActiveModel::Model

  attr_accessor :action

  def at
    Time.current.to_fs(:time_and_date)
  end
end
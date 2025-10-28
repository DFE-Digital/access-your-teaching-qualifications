# frozen_string_literal: true

class ActionAtComponent < ApplicationComponent
  include ActiveModel::Model

  attr_accessor :action

  def at
    Time.use_zone("London") { Time.current.to_fs(:time_and_date) }
  end
end

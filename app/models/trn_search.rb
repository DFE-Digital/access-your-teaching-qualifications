class TrnSearch
  include ActiveModel::Model

  attr_accessor :trn, :searched_at

  validates :trn, presence: true

  def searched_at_to_s
    searched_at.strftime("%-I:%M%P on %-d %B %Y")
  end
end

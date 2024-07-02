class TrnSearch
  include ActiveModel::Model

  attr_accessor :trn

  validates :trn, presence: true

  def find_teacher(teachers:)
    return unless valid?
    teachers.find { |t| t.trn == trn }
  end
end

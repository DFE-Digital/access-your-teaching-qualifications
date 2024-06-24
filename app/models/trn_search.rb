class TrnSearch
  include ActiveModel::Model

  attr_accessor :trn

  validates :trn, presence: true
end

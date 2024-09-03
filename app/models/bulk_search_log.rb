class BulkSearchLog < ApplicationRecord
  belongs_to :dsi_user

  validates :csv, presence: true
  validates :query_count, presence: true
  validates :result_count, presence: true
end

class BulkSearchResponse < ApplicationRecord
  belongs_to :dsi_user

  before_create :expire_other_responses

  private

  def expire_other_responses
    BulkSearchResponse.where(dsi_user:)
                      .where('expires_at > ?', Time.current)
                      .update_all(expires_at: Time.current)
  end
end

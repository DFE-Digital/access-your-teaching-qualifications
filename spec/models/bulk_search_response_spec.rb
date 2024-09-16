require 'rails_helper'

RSpec.describe BulkSearchResponse, type: :model do
  describe 'callbacks' do
    describe '#expire_other_responses' do
      let(:dsi_user) { create(:dsi_user) }
      let!(:old_response) { create(:bulk_search_response, dsi_user:, expires_at: 1.hour.from_now) }

      it 'expires other responses for the same user' do
        expect {
          create(:bulk_search_response, dsi_user:)
        }.to change { old_response.reload.expires_at }.to be_within(1.second).of(Time.current)
      end

      it 'does not expire responses for other users' do
        other_user = create(:dsi_user)
        other_response = create(:bulk_search_response, dsi_user: other_user, expires_at: 1.hour.from_now)

        expect {
          create(:bulk_search_response, dsi_user:)
        }.not_to(change { other_response.reload.expires_at })
      end

      it 'does not affect already expired responses' do
        expired_response = create(:bulk_search_response, dsi_user:, expires_at: 1.hour.ago)

        expect {
          create(:bulk_search_response, dsi_user:)
        }.not_to(change { expired_response.reload.expires_at })
      end
    end
  end
end

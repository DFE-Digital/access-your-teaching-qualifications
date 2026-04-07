class SearchLog < ApplicationRecord
  enum search_type: {
    personal_details: 'personal_details',
    trn: 'trn',
    skip_trn_use_personal_details: 'skip_trn_use_personal_details'
  }

  belongs_to :dsi_user
end

require 'rails_helper'

RSpec.describe BulkSearchLog, type: :model do
  it { is_expected.to validate_presence_of(:csv) }
  it { is_expected.to validate_presence_of(:query_count) }
  it { is_expected.to validate_presence_of(:result_count) }
end

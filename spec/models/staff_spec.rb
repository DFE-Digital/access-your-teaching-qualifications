require "rails_helper"

RSpec.describe Staff, type: :model do
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
end

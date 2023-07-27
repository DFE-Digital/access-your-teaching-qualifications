require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { is_expected.to validate_presence_of(:company_registration_number) }
  it { is_expected.to validate_uniqueness_of(:company_registration_number).case_insensitive }
end

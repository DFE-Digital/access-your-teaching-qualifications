require "rails_helper"

RSpec.describe Qualifications::OneLoginUsers::NameChangeForm, type: :model do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
  it { is_expected.to validate_length_of(:middle_name).is_at_most(100) }
  it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
end

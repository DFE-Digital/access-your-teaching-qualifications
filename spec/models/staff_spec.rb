require "rails_helper"

RSpec.describe Staff, type: :model do
  it { is_expected.to be_a(Devise::Models::Confirmable) }
  it { is_expected.to be_a(Devise::Models::DatabaseAuthenticatable) }
  it { is_expected.to be_a(Devise::Models::Lockable) }
  it { is_expected.to be_a(Devise::Models::Registerable) }
  it { is_expected.to be_a(Devise::Models::Recoverable) }
  it { is_expected.to be_a(Devise::Models::Rememberable) }
  it { is_expected.to be_a(Devise::Models::Timeoutable) }
  it { is_expected.to be_a(Devise::Models::Trackable) }
  it { is_expected.to be_a(Devise::Models::Validatable) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
end

require "rails_helper"

RSpec.describe Search do
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:date_of_birth) }

  describe "#date_of_birth=" do
    subject(:search) { described_class.new(date_of_birth:) }

    context "with a valid date of birth" do
      let(:date_of_birth) { %w[2000 12 1] }

      it "sets the year, month and day correctly" do
        expect(search.date_of_birth.year).to eq("2000")
        expect(search.date_of_birth.month).to eq("12")
        expect(search.date_of_birth.day).to eq("1")
      end
    end

    context "with a missing day" do
      let(:date_of_birth) { %w[2000 12] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include(
          "Enter a day for the date of birth, formatted as a number"
        )
      end
    end

    context "with a missing month" do
      let(:date_of_birth) { ["2000", "", "1"] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include(
          "Enter a month for the date of birth, formatted as a number"
        )
      end
    end

    context "with a short month name" do
      let(:date_of_birth) { %w[2000 Jan 1] }

      it "converts the month to a number" do
        expect(search.date_of_birth.month).to eq("1")
      end
    end

    context "with a word for a number for the day and month" do
      let(:date_of_birth) { %w[2000 tWeLvE One] }

      it "sets the year, month and day correctly" do
        expect(search.date_of_birth.year).to eq("2000")
        expect(search.date_of_birth.month).to eq("12")
        expect(search.date_of_birth.day).to eq("1")
      end
    end

    context "with an invalid date" do
      let(:date_of_birth) { %w[2000 02 30] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include("Enter a valid date of birth")
      end
    end

    context "when the date is in the future" do
      let(:date_of_birth) { [Time.zone.today.year + 1, 1, 1] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include("Date of birth must be in the past")
      end
    end

    context "with a date less than 16 years ago" do
      let(:date_of_birth) { [15.years.ago.year, 1, 1] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include(
          "People must be 16 or over to use this service"
        )
      end
    end

    context "with a date before 1900" do
      let(:date_of_birth) { %w[1899 1 1] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include("Enter a year of birth later than 1900")
      end
    end

    context "with a year that is less than 4 digits" do
      let(:date_of_birth) { %w[99 1 1] }

      it "is invalid" do
        expect(search).to be_invalid
        expect(search.errors[:date_of_birth]).to include("Enter a year with 4 digits")
      end
    end
  end

  describe "#date_of_birth" do
    let(:date_of_birth) { %w[2000 12 1] }

    subject { described_class.new(date_of_birth:).date_of_birth }

    it "responds to to_s" do
      expect(subject.to_s).to eq("2000-12-01")
    end
  end
end

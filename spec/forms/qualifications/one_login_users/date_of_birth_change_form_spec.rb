require "rails_helper"

RSpec.describe Qualifications::OneLoginUsers::DateOfBirthChangeForm, type: :model do
  describe "evidence content type validation" do
    it "accepts a file whose content matches its declared type" do
      {
        "test-upload.pdf" => "application/pdf",
        "test-upload.png" => "image/png",
        "test-upload.jpg" => "image/jpeg",
      }.each do |fixture, declared_type|
        form = build_form(fixture:, declared_type:)
        form.valid?
        expect(form.errors[:evidence]).to be_empty
      end
    end

    it "rejects a file whose content does not match its declared type" do
      # An HTML file uploaded with a spoofed extension and Content-Type header
      form = build_form(fixture: "html-file-with-pdf-extension.pdf",
                        declared_type: "application/pdf")
      form.valid?
      expect(form.errors[:evidence]).to include("The selected file must be a PDF, JPG, JPEG or PNG")
    end

    it "rejects a file whose declared type is not allowed" do
      form = build_form(fixture: "html-file-with-pdf-extension.pdf", declared_type: "text/html")
      form.valid?
      expect(form.errors[:evidence]).to include("The selected file must be a PDF, JPG, JPEG or PNG")
    end

    def build_form(fixture:, declared_type:)
      fixture_path = Rails.root.join("spec/fixtures", fixture)
      described_class.new(
        day: "5",
        month: "12",
        year: "1990",
        evidence: Rack::Test::UploadedFile.new(fixture_path, declared_type),
      )
    end
  end
end

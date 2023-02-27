require "rails_helper"

RSpec.describe "Health check", type: :request do
  describe "GET /health" do
    it "responds successfully" do
      get "/health"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /health/all" do
    before do
      allow(Notifications::Client).to receive(:new).and_return(
        double(:client, send_email: true)
      )
    end

    it "responds successfully" do
      get "/health/all"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /health/postgresql" do
    it "responds successfully" do
      get "/health/postgresql"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /health/version" do
    it "responds successfully" do
      get "/health/version"
      expect(response).to have_http_status(:ok)
    end
  end

  it "checks Notify integration health" do
    allow(Notifications::Client).to receive(:new).and_return(
      double(:client, send_email: true)
    )
    get "/health/notify"
    expect(response).to have_http_status(:ok)
  end
end

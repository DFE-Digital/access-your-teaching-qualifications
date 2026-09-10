require "rails_helper"
require "rake"

RSpec.describe TrimSessionsJob do
  describe "#perform" do
    # Rake marks a task invoked and refuses to run it again, so in a long-lived
    # Sidekiq process the trim deleted nothing after the pod's first run.
    it "trims on a second invocation, not just the first" do
      stale_session
      described_class.perform_now
      stale_session

      expect { described_class.perform_now }
        .to change(ActiveRecord::SessionStore::Session, :count).from(1).to(0)
    end

    # load_tasks appends to tasks that already exist rather than replacing them.
    it "does not give the task another body each time it runs" do
      described_class.perform_now
      actions = Rake::Task["db:sessions:trim"].actions.size

      described_class.perform_now

      expect(Rake::Task["db:sessions:trim"].actions.size).to eq actions
    end
  end

  def stale_session
    ActiveRecord::SessionStore::Session.create!(session_id: SecureRandom.hex, data: "e30=")
      .update_column(:updated_at, 60.days.ago)
  end
end

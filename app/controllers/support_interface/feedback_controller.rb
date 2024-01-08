class SupportInterface::FeedbackController < SupportInterface::SupportInterfaceController
  include Pagy::Backend

  def index
    @pagy, @feedback = pagy(Feedback.order(created_at: :desc))
  end
end

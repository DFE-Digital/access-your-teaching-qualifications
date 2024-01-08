class SupportInterface::FeedbackController < SupportInterface::SupportInterfaceController
  def index
    @feedback = Feedback.order(created_at: :desc)
  end

  def show
    @feedback = Feedback.find(params[:id])
  end
end

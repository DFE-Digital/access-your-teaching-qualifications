module Qualifications
  class FeedbacksController < QualificationsInterfaceController
    def new
      @feedback = Feedback.new
    end

    def create
      @feedback = Feedback.new(feedback_params)
      @feedback.service = :aytq

      if @feedback.save
        redirect_to qualifications_success_path
      else
        render :new
      end
    end

    private

    def feedback_params
      params.require(:feedback).permit(
        :satisfaction_rating,
        :improvement_suggestion,
        :contact_permission_given,
        :email
      )
    end
  end
end

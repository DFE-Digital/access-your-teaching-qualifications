module CheckRecords
  class FeedbacksController < CheckRecordsController
    def new
      @feedback = Feedback.new
    end

    def create
      @feedback = Feedback.new(feedback_params)
      @feedback.service = :check

      if @feedback.save
        redirect_to check_records_success_path
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

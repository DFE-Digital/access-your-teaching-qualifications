module CheckRecords
  class TeachersController < CheckRecordsController
    def show
      client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
      trn = SecureIdentifier.decode(params[:id])
      @teacher = client.teacher(trn:)
      @npqs = @teacher.qualifications.filter(&:npq?)
      @mqs = @teacher.qualifications.filter(&:mq?)
      @other_qualifications = @teacher.qualifications.reject do |qualification|
        qualification.npq? || qualification.mq?
      end
    rescue QualificationsApi::TeacherNotFoundError
      respond_to do |format|
        format.html { render "not_found", locals: { trn: SecureIdentifier.decode(params[:id]) } } 
        format.any { head :not_found }
      end
    end
  end
end

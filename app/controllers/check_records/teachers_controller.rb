module CheckRecords
  class TeachersController < CheckRecordsController
    def show
      client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
      trn = SecureIdentifier.decode(params[:id])
      @teacher = client.teacher(trn:)
      @npqs = @teacher.qualifications.filter(&:npq?)
      @other_qualifications = @teacher.qualifications.filter { |qualification| !qualification.npq? }
    rescue QualificationsApi::TeacherNotFoundError
      render "not_found"
    end
  end
end

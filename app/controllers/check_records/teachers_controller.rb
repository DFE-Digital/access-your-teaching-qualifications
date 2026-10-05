module CheckRecords
  class TeachersController < CheckRecordsController
    class InvalidTrn < StandardError; end

    # Looser than today's seven digits so a change to the TRN format doesn't
    # turn every record into not found.
    TRN_FORMAT = /\A\d{1,12}\z/

    def show
      client = QualificationsApi::Client.new(token: ENV["QUALIFICATIONS_API_FIXED_TOKEN"])
      @teacher = client.teacher(trn:)
      @npqs = @teacher.qualifications.filter(&:npq?)
      @mqs = @teacher.qualifications.filter(&:mq?)
      @other_qualifications = @teacher.qualifications.reject do |qualification|
        qualification.npq? || qualification.mq?
      end
    rescue SecureIdentifier::InvalidIdentifier, InvalidTrn, QualificationsApi::TeacherNotFoundError
      respond_to do |format|
        format.html { render "not_found" }
        format.any { head :not_found }
      end
    end

    private

    # The identifier is encrypted without a MAC, so a forged one can decrypt
    # to junk rather than failing outright.
    def trn
      decoded = SecureIdentifier.decode(params[:id])
      raise InvalidTrn, "expected 1 to 12 digits" unless decoded.match?(TRN_FORMAT)

      decoded
    end
  end
end

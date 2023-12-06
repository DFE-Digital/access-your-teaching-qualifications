module DfESignInApi
  class GetStaffAccessToService < GetUserAccessToService

    private

    def authorised_role_codes
      ENV.fetch("DFE_SIGN_IN_API_STAFF_ROLE_CODES").split(",")
    end
  end
end

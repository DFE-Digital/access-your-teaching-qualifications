module SupportInterface
  class StaffController < SupportInterfaceController
    def index
      @staff = DsiUser.staff
    end
  end
end

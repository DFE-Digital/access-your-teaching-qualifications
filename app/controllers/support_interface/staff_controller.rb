module SupportInterface
  class StaffController < SupportInterfaceController
    def index
      @staff = DsiUser.internal.order(:last_name, :first_name)
    end
  end
end

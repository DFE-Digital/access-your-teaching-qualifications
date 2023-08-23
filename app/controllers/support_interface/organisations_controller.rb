class SupportInterface::OrganisationsController < SupportInterface::SupportInterfaceController
  def index
    @organisations = Organisation.all
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)

    if @organisation.save
      flash[:success] = 'Organisation created'
      redirect_to support_interface_organisations_path
    else
      render :new
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:company_registration_number)
  end
end

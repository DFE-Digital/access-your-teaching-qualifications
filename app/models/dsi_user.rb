class DsiUser < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :first_name, :last_name

  def self.create_or_update_from_dsi(dsi_payload)
    dsi_user = find_or_initialize_by(email: dsi_payload.info.fetch(:email))

    dsi_user.update!(
      first_name: dsi_payload.info.first_name,
      last_name: dsi_payload.info.last_name,
      uid: dsi_payload.uid
    )

    dsi_user.organisation =
      Organisation.find_by(
        company_registration_number:
          dsi_payload.extra.dig(
            "raw_info",
            "organisation",
            "companyRegistrationNumber"
          )
      )

    dsi_user
  end

  attr_accessor :organisation

  def valid_organisation?
    organisation.present?
  end
end

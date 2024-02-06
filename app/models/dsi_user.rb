class DsiUser < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :first_name, :last_name

  has_many :search_logs
  has_many :dsi_user_sessions, dependent: :destroy

  def self.create_or_update_from_dsi(dsi_payload, role: nil)
    dsi_user = find_or_initialize_by(email: dsi_payload.info.fetch(:email))

    dsi_user.update!(
      first_name: dsi_payload.info.first_name,
      last_name: dsi_payload.info.last_name,
      uid: dsi_payload.uid,
    )

    if role.present?
      dsi_user.dsi_user_sessions.create!(
        role_id: role["id"],
        role_code: role["code"],
        organisation_id: dsi_payload.extra.raw_info.organisation.id,
        organisation_name: dsi_payload.extra.raw_info.organisation.name,
      )
    end

    dsi_user
  end

  def internal?
    DfESignIn.bypass? || current_session&.role_code == ENV.fetch("DFE_SIGN_IN_API_INTERNAL_USER_ROLE_CODE")
  end

  def current_session
    dsi_user_sessions.order(created_at: :desc).first
  end

  def last_sign_in_at
    dsi_user_sessions.order(created_at: :desc).first&.created_at
  end
end

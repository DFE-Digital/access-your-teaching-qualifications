class DsiUser < ApplicationRecord
  encrypts :email, deterministic: true
  encrypts :first_name, :last_name

  has_many :search_logs
  has_many :dsi_user_sessions, dependent: :destroy
  has_many :bulk_search_responses

  CURRENT_TERMS_AND_CONDITIONS_VERSION = "1.0".freeze

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
    DfESignIn.bypass? || Role.enabled.internal.pluck(:code).include?(current_session&.role_code)
  end

  def current_session
    dsi_user_sessions.order(created_at: :desc).first
  end

  def last_sign_in_at
    dsi_user_sessions.order(created_at: :desc).first&.created_at
  end

  def accept_terms!
    update!(
      terms_and_conditions_version_accepted: CURRENT_TERMS_AND_CONDITIONS_VERSION,
      terms_and_conditions_accepted_at: Time.zone.now
    )
  end

  def acceptance_required?
    !current_version_accepted || acceptance_expired
  end

  def current_version_accepted
    terms_and_conditions_version_accepted == CURRENT_TERMS_AND_CONDITIONS_VERSION
  end

  def acceptance_expired
    terms_and_conditions_accepted_at < 12.months.ago
  end
end

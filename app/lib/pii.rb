module Pii
  # Every encrypted column in the application. The set is fixed, so it is named
  # here rather than rediscovered from the models on each row, and the conversion
  # and the check that gates it agree by construction.
  #
  # spec/config/encryption_spec.rb asserts both of these still match what the
  # models declare, so an attribute added or its determinism changed cannot drift
  # out of scope unnoticed.
  ENCRYPTED_ATTRIBUTES = {
    "User" => %i[email family_name given_name name one_login_verified_name],
    "DsiUser" => %i[email first_name last_name],
    "Console1984::Command" => %i[statements],
    "Audits1984::Audit" => %i[notes]
  }.freeze

  # The ones a lookup can silently miss on, and the only ones the conversion has
  # to read by hand.
  DETERMINISTIC_ATTRIBUTES = {
    "User" => %i[email],
    "DsiUser" => %i[email]
  }.freeze

  MODEL_NAMES = ENCRYPTED_ATTRIBUTES.keys.freeze
end

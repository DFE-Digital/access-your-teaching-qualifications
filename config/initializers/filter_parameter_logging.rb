# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += %i[
  passw
  secret
  token
  _key
  crypt
  salt
  otp
  ssn
  last_name
  date_of_birth
  birth_date
  first_name
  middle_name
]

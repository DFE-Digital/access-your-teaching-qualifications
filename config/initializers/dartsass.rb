Rails.application.config.dartsass.builds = {
  "certificates.scss" => "certificates.css",
  "check_records.scss" => "check_records.css",
  "qualifications.scss" => "qualifications.css"
}

Rails.application.config.dartsass.build_options << "--load-path=node_modules"

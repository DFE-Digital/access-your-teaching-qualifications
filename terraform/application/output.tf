output "urls" {
  value = [
    module.web_application.url,
    "https://${local.check_domain}"
  ]
}

output "external_urls" {
  value = [
    "https://${local.access_external_domain}",
    "https://${local.check_external_domain}"
  ]
  description = "List of external URLs for the application"
}

output "urls" {
  value = [
    module.web_application.url,
    "https://${local.check_domain}"
  ]
}

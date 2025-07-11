# Used to create domains to be managed by front door.
module "domains" {
  for_each            = var.hosted_zone
  source              = "./vendor/modules/domains//domains/environment_domains"
  zone                = each.key
  front_door_name     = each.value.front_door_name
  resource_group_name = each.value.resource_group_name
  domains             = each.value.domains
  environment         = each.value.environment_short
  host_name           = each.value.origin_hostname
  null_host_header    = try(each.value.null_host_header, false)
  cached_paths        = try(each.value.cached_paths, [])
  redirect_rules      = try(each.value.redirect_rules, [])
  rate_limit          = try(var.rate_limit, null)
  rate_limit_max      = try(var.rate_limit_max, null)
  allow_aks           = try(var.allow_aks, null)
}

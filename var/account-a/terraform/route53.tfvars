# ======================================================================================================================
# route 53 variables
# ======================================================================================================================
r53_zones = {
  "mobiliseacademyrs.mobilise.academy" = {
    create_r53_zones = true
    domain_name     = "mobiliseacademyrs.mobilise.academy"
    private_zone    = false
    comment         = "public-dns-zone"
  }
}

r53_alias_local_nlb = {
  "www-lb" = {
    "create_record"          = true
    "zone"                   = "mobiliseacademyrs.mobilise.academy"
    "domain_name_prefix"     = "www-lb"
    "nlb"                    = "squid_nlb"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}
r53_alias_local_cf = {
  "www" = {
    "create_record"          = true
    "zone"                   = "mobiliseacademyrs.mobilise.academy"
    "domain_name_prefix"     = "www"
    "cf_distributions"       = "mob_academy_cf"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}
r53_alias_local_s3 = {
  "assets" = {
    "create_record"          = true
    "zone"                   = "mobiliseacademyrs.mobilise.academy"
    "domain_name_prefix"     = "assets"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}

# ======================================================================================================================
# route 53 variables
# ======================================================================================================================
r53_zones = {
  "internal.mobilise.academy" = {
    create_r53_zones = true
    domain_name      = "internal.mobilise.academy"
    private_zone     = true
  }
}

r53_alias_local_alb = {
  "wp-lb" = {
    "create_record"          = true
    "zone"                   = "internal.mobilise.academy"
    "domain_name_prefix"     = "wp-lb"
    "alb"                    = "wordpress_alb"
    "record_type"            = "A"
    "evaluate_target_health" = false
  }
}
r53_cname_local_db = {
  "database" = {
    "create_record"      = true
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "database"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "db"                 = "aurora_cluster_instance_1"
  }
}
r53_cname_local_mem = {
  "cache" = {
    "create_record"      = true
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "cache"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "mem"                = "memcached_cluster"
  }
}
r53_cname_local_efs = {
  "storage" = {
    "create_record"      = true
    "zone_id"            = "internal.mobilise.academy"
    "domain_name_prefix" = "storage"
    "record_type"        = "CNAME"
    "ttl"                = "300"
    "efs"                = "efs_01"
  }
}

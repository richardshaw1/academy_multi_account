# ===================================================================================================================
# Route53 for routing internet traffic
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "r53_zones" {
  type        = map(any)
  description = "A map of route 53 zones"
  default     = {}
}
variable "r53_cname_local_efs" {
  type        = map(any)
  description = "A map of cname record addresses for efs"
  default     = {}
}
variable "r53_alias_local_nlb" {
  type        = map(any)
  description = "a map holding record set info for local connections via the network load balancer"
  default     = {}
}
variable "r53_alias_local_alb" {
  type        = map(any)
  description = "a map holding record set info for local connections via the application load balancer"
  default     = {}
}
variable "r53_alias_local_cf" {
  type        = map(any)
  description = "a map holding record set info for local connections for cloudfront distribution"
  default     = {}
}
variable "r53_alias_local_s3" {
  type        = map(any)
  description = "a map holding record set info for local connections for the s3 bucket"
  default     = {}
}
variable "r53_cname_local_db" {
  type        = map(any)
  description = "a map holding record set info for local connections to the database"
  default     = {}
}
variable "r53_cname_local_mem" {
  type        = map(any)
  description = "a map holding record set info for local connections to elasticache memcached"
  default     = {}
}
# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route 53 Zones
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_zone" "env_r53_zones" {
  for_each = { for key, value in var.r53_zones :
    key => value
  if lookup(value, "create_r53_zones", false) == true }
  name    = lookup(each.value, "domain_name", "")
  comment = "dns-zone"

  tags = "${merge(
    local.default_tags
  )}"

lifecycle {
  ignore_changes = [vpc]
}
  

  dynamic "vpc" {
    for_each = { for key, value in var.r53_zones :
      key => value
    if lookup(value, "private_zone", false) == true }
    content {
      vpc_id = aws_vpc.env_vpc[0].id
    }
  }
}
# ======================================================================================================================
# route 53 routes
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account application load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_alb" {
  for_each = { for key, value in var.r53_alias_local_alb :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_lb.env_alb[lookup(each.value, "alb", "")].dns_name
    zone_id                = aws_lb.env_alb[lookup(each.value, "alb", "")].zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_lb.env_alb]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account aurora database
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_db" {
  for_each = { for key, value in var.r53_cname_local_db :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_rds_cluster_instance.db_cluster_instance[lookup(each.value, "db", "")].endpoint]
  depends_on = [aws_rds_cluster_instance.db_cluster_instance]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account memcached cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_mem" {
  for_each = { for key, value in var.r53_cname_local_mem :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_elasticache_cluster.elasticache_cluster[lookup(each.value, "mem", "")].configuration_endpoint]
  depends_on = [aws_elasticache_cluster.elasticache_cluster]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the cname type record set. local account efs
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_cname_local_efs" {
  for_each = { for key, value in var.r53_cname_local_efs :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id    = aws_route53_zone.env_r53_zones[lookup(each.value, "zone_id", "")].id
  name       = lookup(each.value, "domain_name_prefix", "")
  type       = lookup(each.value, "record_type", "")
  ttl        = lookup(each.value, "ttl", "")
  records    = [aws_efs_file_system.efs[lookup(each.value, "efs", "")].dns_name]
  depends_on = [aws_efs_file_system.efs]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account network load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_nlb" {
  for_each = { for key, value in var.r53_alias_local_nlb :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_lb.env_lb_nlb[lookup(each.value, "nlb", "")].dns_name
    zone_id                = aws_lb.env_lb_nlb[lookup(each.value, "nlb", "")].zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_lb.env_lb_nlb]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account cloudfront
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_cf" {
  for_each = { for key, value in var.r53_alias_local_cf :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_cloudfront_distribution.cf_distribution[lookup(each.value, "cf_distributions", "")].domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution[lookup(each.value, "cf_distributions", "")].hosted_zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_cloudfront_distribution.cf_distribution]
}
# ----------------------------------------------------------------------------------------------------------------------
# route traffic through the defined domains using the a type record set. local account s3 bucket
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route53_record" "env_r53_alias_local_s3" {
  for_each = { for key, value in var.r53_alias_local_s3 :
    key => value
  if lookup(value, "create_record", false) == true }
  zone_id = aws_route53_zone.env_r53_zones[lookup(each.value, "zone", "")].id
  name    = lookup(each.value, "domain_name_prefix", "")
  type    = lookup(each.value, "record_type", "")
  alias {
    name                   = aws_s3_bucket_website_configuration.assets[0].website_endpoint
    zone_id                = aws_s3_bucket.assets[0].hosted_zone_id
    evaluate_target_health = lookup(each.value, "evaluate_target_health", "")
  }
  depends_on = [aws_s3_bucket.assets]
}
# ----------------------------------------------------------------------------------------------------------------------
# AWS Certificate Manager
# ----------------------------------------------------------------------------------------------------------------------
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "us_east_1_certs_to_create" {
  type        = map(any)
  description = "A map of public certificates to create in the us-east-1 region. Needed for Cloudfront"
  default     = {}
}

# ===================================================================================================================
# RESOURCE CREATION 
# ===================================================================================================================
resource "aws_acm_certificate" "env_us_east_1_create_cert" {
  for_each = { for key, value in var.us_east_1_certs_to_create :
    key => value
  if lookup(value, "create_certificate", false) == true }
  provider                  = aws.us-east-1
  domain_name               = lookup(each.value, "domain_name", "")
  validation_method         = lookup(each.value, "validation_method", "DNS")
  subject_alternative_names = lookup(each.value, "sans", [])
  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${lookup(each.value, "tag_cert_name", "")}"
    },
  )
}
# ===================================================================================================================
# Key Management Service
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_ebs_kms_key" {
  description = "Create an EBS KMS key if needed. Default false."
  default     = false
}

variable "kms_keys" {
  description = "A map of KMS keys to create"
  default     = {}
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create a standard environment EBS KMS Key
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "ebs_key" {
  count                   = var.create_ebs_kms_key ? 1 : 0
  description             = "EBS Volume encryption key"
  deletion_window_in_days = 30

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-ebs-key"
    },
  )
}

resource "aws_kms_key" "env_ebs_key" {
  for_each = { for key, value in var.kms_keys :
    key => value
  if lookup(value, "create_key", false) == true }
  description             = lookup(each.value, "description", "")
  deletion_window_in_days = lookup(each.value, "deletion_window_in_days", null)
  policy = lookup(each.value, "accounts", null) == null ? null : replace(templatefile("${path.module}/templates/other_policy/kms_key_policy_cross_account.json", {
    accounts = lookup(each.value, "accounts", [])
  }), "/,\\s*([^,]+)$/", "]}}]}")
}
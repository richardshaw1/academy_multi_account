# ===================================================================================================================
# Elastic File System - EFS
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================

variable "create_efs" {
  default = false
}

variable "efs" {
  default = {}
}

variable "efs_backup_policy" {
  default = {}
}

variable "ef_stores" {
  description = "map of EFS and associated security groups"
  default     = {}
}

variable "efs_mount_targets" {
  description = "A map of the mount targets linked to each file system"
  default     = {}
}

# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
resource "aws_efs_file_system" "efs" {
  for_each         = var.ef_stores
  encrypted        = lookup(each.value, "encrypted", "")
  kms_key_id       = lookup(each.value, "kms_key", "")
  performance_mode = lookup(each.value, "performance_mode", "")
  throughput_mode  = lookup(each.value, "throughput_mode", "")

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  tags = merge(
    local.default_tags,
    {

      "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = lookup(each.value, "tag_project", "")
    },
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Elastic File System Mount Target
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each        = var.efs_mount_targets
  file_system_id  = aws_efs_file_system.efs[lookup(each.value, "ef_store", "")].id
  security_groups = [aws_security_group.ec2_sg[lookup(each.value, "security_group", "")].id]
  subnet_id       = aws_subnet.env_subnet[lookup(each.value, "subnet", "")].id
  ip_address      = lookup(each.value, "ip_address", null)
}

resource "aws_efs_backup_policy" "efs_backup_policy" {
  for_each       = var.efs_backup_policy
  file_system_id = aws_efs_file_system.efs[lookup(each.value, "ef_store_name", "")].id

  backup_policy {
    status = lookup(each.value, "status", "")
  }
}
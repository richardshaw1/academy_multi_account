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

resource "aws_efs_file_system" "efs" {
  for_each = { for key, value in var.efs :
    key => value
  if lookup(value, "create_efs", false) == true }

  creation_token = lookup(each.value, "creation_token", "")

  tags = merge(
    local.default_tags,
    {

      "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = lookup(each.value, "tag_project", "")
    },
  )
}

/* resource "aws_efs_backup_policy" "efs_backup_policy" {
  for_each = { for key, value in var.efs_backup_policy :
  key => value }
  file_system_id = ""

  backup_policy {
    status = lookup(each.value, "status", "")
  }
} */
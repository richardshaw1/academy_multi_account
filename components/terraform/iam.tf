# ===================================================================================================================
# Identity and Access Management - Roles, policies and policy attachments
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================

variable "create_iam_user" {
  default = false
}
variable "iam_groups" {
  description = "list of iam group names"
  default     = []
}

variable "iam_group_policies" {
  description = "A map of group to policy mappings"
  default     = {}
}

variable "iam_group_membership_name" {
  description = "A map of group membership names"
  default     = {}
}

variable "iam_users" {
  description = "A map of all users to create"
  type = string
  default     = ""
}

variable "iam_user_policy_name" {
  description = "name of iam user policy"
  default     = {}
}


variable "iam_user_policy_01" {
  description = "s3 full access user policy"
  default     = {}
}

variable "iam_role_policy" {
  description = "A map of all users to create"
  default     = {}
}
variable "create_iam_ssm_pm" {
  description = "Create IAM role to support Patch Manager in AWS SSM"
  default     = false
}

variable "iam_role_policy_templates" {
  type = map
  description = "map of the role policy templates to create"
  default = {}
}

variable "iam_user_policy_templates" {
  type = map
  description = "map of the uwer policy templates to create"
  default = {}
}
variable "iam_group_policy_templates" {
  type = map
  description = "map of the group policy templates to create"
  default = {}
}

# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
# -------------------------------------------------------------------------------------------------------------------
# IAM groups
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group" "mobilise_academy_group" {
  count    = var.create_iam_user ? 1 : 0
  name     = var.iam_groups
}

resource "aws_iam_group_policy" "iam_group_policy" {
  for_each = var.iam_group_policies
  name     = lookup(each.value, "group_name", "")
  policy   = file("./templates/workshop_s3_deny_delete.json")
  group    = lookup(each.value, "iam_groups", "")
}

# -------------------------------------------------------------------------------------------------------------------
# IAM Users and their group membership
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "mobilise_academy" {
  count    = var.create_iam_user ? 1 : 0
  name     = var.iam_users
}

resource "aws_iam_user_policy" "s3_full_access" {
  count = var.create_iam_user ? 1 : 0
  name     = var.iam_user_policy_name
  user     = var.iam_users
  policy   = file("./templates/s3_full_access.json")
}
resource "aws_iam_user_group_membership" "mobiliseacademygroup_membership" {
  count  = var.create_iam_user ? 1 : 0
  user   = aws_iam_user.mobilise_academy[0].name
  groups = [aws_iam_group.mobilise_academy_group[0].name]
}


# -------------------------------------------------------------------------------------------------------------------
# Roles
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "instance_iam_role" {
  name               = "instance-iam-role"
  assume_role_policy = file("./templates/s3_full_access.json")


  tags = {
    tag-key = "tag-value"
  }
}
# -------------------------------------------------------------------------------------------------------------------
# Policies
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "ssm_policy" {
  for_each = var.iam_role_policy_templates
  name   = lookup(each.value, "name", "")
  role   = aws_iam_role.instance_iam_role.id
  policy = file("./templates/ssm_managed_instance_core.json")
}
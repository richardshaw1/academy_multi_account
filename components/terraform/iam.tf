# ===================================================================================================================
# Identity and Access Management - Roles, policies and policy attachments
# Global-Admin created manually. IAM-Admin, Read-Only and ${environment}-Admin created automatcally below. All other
# roles require active configuration within tfvars of each account.
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "iam_groups" {
  description = "A List of iam groups"
  default     = []
}

variable "sts_policies" {
  description = "A map of policies that assign account numbers to a policy resource for sts assume role in other accounts"
  default     = {}
}

variable "sts_policies_2" {
  description = "A map of policies that assign account numbers to a policy resource for sts assume role in other accounts"
  default     = {}
}

variable "aws_policies" {
  description = "A map of AWS policies that can be attached to a role"
  default     = {}
}

variable "iam_group_polices" {
  description = "A map of group to policy mappings"
  default     = {}
}

variable "service_linked_roles" {
  description = "A map of IAM service linked roles such as AWSServiceRoleForOrganizations and AWSServiceRoleForTtrsutedAdvisor"
  default     = {}
}

variable "iam_users" {
  description = "A map of all users to create"
  default     = {}
}

variable "iam_trust_services_roles" {
  description = "A map of all the roles to be created with a trust relationship with a principal service"
  default     = {}
}

variable "iam_trust_roles" {
  description = "A map of all the roles to be created with a trust relationship with a principal AWS role"
  default     = {}
}

variable "iam_trust_roles_mfa" {
  description = "A map of all the roles to be created with a trust relationship with a principal AWS role and MFA enabled"
  default     = {}
}

variable "policy_templates" {
  description = "A map of all policies to create that use a template in templates/iam_policy that require no variables"
  default     = {}
}

variable "policy_template_roles_accs" {
  description = "A map of all policies to create that use a template in templates/iam_policy that require accountid and applied role"
  default     = {}
}

variable "iam_role_pol_atts" {
  description = "A map of all policies attached to roles"
  default     = {}
}

variable "codebuild_service_role_pol_atts" {
  description = "A map of policies attached to codebuild service roles"
  default     = {}
}

variable "third_party_policies" {
  description = "A map of policies to create for third party access to AWS Console"
  default     = {}
}

variable "iam_minor_account" {
  description = "A flag to signal this is an account in a different region with IAM roles created in the main region"
  default     = false
}

variable "ec2_ip_pol_att_arn" {
  description = "A map of policies to attatch to a role"
  default     = {}
}

variable "ec2_ip_sts_policies" {
  description = "A map of policies to create"
  default     = {}
}

variable "ec2_ip_pols" {
  description = "A map of policies to create"
  default     = {}
}

variable "ec2_ip_pol_att_sts_template" {
  description = "A map of policies to attatch to a role"
  default     = {}
}

variable "ec2_ip_pol_att_template" {
  description = "A map of policies to attatch to a role"
  default     = {}
}

variable "create_iam_ssm_pm" {
  description = "Create IAM role to support Patch Manager in AWS SSM"
  default     = false
}


# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
# -------------------------------------------------------------------------------------------------------------------
# IAM groups
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group" "mobilise_academy_group" {
  name = "mobilise-academy-group"
}

resource "aws_iam_group_policy" "workshop_s3_deny_delete_policy" {
  name   = "${var.environment}-workshop-s3-deny-delete-policy"
  policy = file("./templates/workshop_s3_deny_delete.json")
  group  = aws_iam_group.mobilise_academy_group.name
}

# -------------------------------------------------------------------------------------------------------------------
# IAM Users and their group membership
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "mobilise_academy" {
  name = "mobilise-academy"
}

resource "aws_iam_user_policy" "s3_full_access" {
  name   = "s3-full-access-policy"
  user   = aws_iam_user.mobilise_academy.name
  policy = file("./templates/s3_full_access.json")
}

resource "aws_iam_group_membership" "mobilise_academy" {
  name  = "mobilise-academy-group-membership"
  users = [aws_iam_user.mobilise_academy.name]
  group = aws_iam_group.mobilise_academy_group.name
}

# -------------------------------------------------------------------------------------------------------------------
# Roles
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "instance_iam_role" {
  name = "instance-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# -------------------------------------------------------------------------------------------------------------------
# Policies
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy" "ssm_policy" {
  name   = "ssm-policy"
  role   = aws_iam_role.instance_iam_role.id
  policy = file("./templates/ssm_managed_instance_core.json")
}
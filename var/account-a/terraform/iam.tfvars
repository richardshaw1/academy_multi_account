# -------------------------------------------------------------------------------------------------------------------
# IAM Variables
# -------------------------------------------------------------------------------------------------------------------
create_iam_user      = true
iam_users            = "mobilise_academy"
iam_user_policy_name = "s3_full_access"
iam_group_policy     = "workshop_s3_deny_delete"
iam_role_01_name     = "academy-iam-profile"
iam_groups           = "mobilise-academy-group"

iam_role_01_policy_01_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
iam_role_01_policy_02_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

iam_group_policies = {
  "workshop_s3_deny_delete" = {
    "group_name" = "workshop-s3-deny-delete"
    /* "policy" = "workshop_s3_deny_delete.json" */
    "policy_arn" = "arn:aws:iam::784943245565:policy/Workshop-S3-Deny-Delete"
  }
}

iam_group_policy_templates = {
  "workshop_s3_deny_delete" = {
    "name"        = "workshop-s3-deny-delete"
    "description" = "deny deletion of object in bucket"
    "policy"      = "workshop_s3_deny_delete.json"
  }
}
iam_group_membership_name = "mobilise-academy-group-membership"

iam_user_policy_templates = {
  "s3_full_access" = {
    "name"        = "s3-full-access"
    "description" = "allow full access to s3"
    "policy"      = "s3_full_access.json"
  }
}

iam_role_policy_templates = {
  "ssm_managed_instance_core" = {
    "name"        = "ssm-managed-instance-core"
    "description" = "policy to use ssm for managing instances"
    "policy"      = "ssm_managed_instance_core.json"
  }
}
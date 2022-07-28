# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
# -------------------------------------------------------------------------------------------------------------------
# IAM Groups
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_group" "Mobilise_Academy_Group" {
  name = "Mobilise-Academy-Group"
}

resource "aws_iam_group_policy" "workshop_s3_deny_delete_policy" {
  name   = "${var.environment}-workshop-s3-deny-delete-policy"
  policy = file("./templates/workshop_s3_deny_delete.json")
  group  = aws_iam_group.Mobilise_Academy_Group.name
}

# -------------------------------------------------------------------------------------------------------------------
# IAM Users and their group membership
# -------------------------------------------------------------------------------------------------------------------
resource "aws_iam_user" "Mobilise_Academy" {
  name = "Mobilise-Academy"
}

resource "aws_iam_user_policy" "s3_full_access" {
  name   = "s3-full-access-policy"
  user   = aws_iam_user.Mobilise_Academy.name
  policy = file("./templates/s3_full_access.json")
}

resource "aws_iam_group_membership" "Mobilise_Academy" {
  name  = "Mobilise-Academy-group-membership"
  users = [aws_iam_user.Mobilise_Academy.name]
  group = aws_iam_group.Mobilise_Academy_Group.name
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
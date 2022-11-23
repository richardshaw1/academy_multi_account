# ======================================================================================================================
# Autoscaling groups - ASG defined in asg.tfvars
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "asgs" {
  type        = map(any)
  description = "A map of all autoscaling groups to create"
  default     = {}
}

variable "lts" {
  type        = map(any)
  description = "A map of all launch templates to create"
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# Launch Template
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "env_lt" {
  for_each = { for key, value in var.lts :
    key => value
  if lookup(value, "create_lt", false) == true }
  name                   = lookup(each.value, "lt_name", "")
  description            = lookup(each.value, "lt_description", "")
  instance_type          = lookup(each.value, "instance_type", "")
  image_id               = lookup(each.value, "ami_id", "")
  key_name               = lookup(each.value, "ec2_account_key_name", "")
  vpc_security_group_ids = [for sg in lookup(each.value, "lt_sgs", []) : aws_security_group.ec2_sg[sg].id]

  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "lt_name", "")
    }
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(
      local.default_tags,
      {
        "Name" = lookup(each.value, "lt_name", "")
      }
    )
  }
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      local.default_tags,
      {
        "Name" = lookup(each.value, "lt_name", "")
      }
    )
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Auto Scaling Group
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "env_asg" {
  for_each = { for key, value in var.asgs :
    key => value
  if lookup(value, "create_asg", false) == true }
  name                      = "${local.name_prefix}-${lookup(each.value, "asg_name", "")}"
  vpc_zone_identifier       = [for sn in lookup(each.value, "asg_subnets", []) : aws_subnet.env_subnet[sn].id]
  max_size                  = lookup(each.value, "asg_max_size", "")
  min_size                  = lookup(each.value, "asg_min_size", "")
  desired_capacity          = lookup(each.value, "asg_desired_capacity", "")
  health_check_grace_period = lookup(each.value, "health_check_grace_period", "")
  health_check_type         = lookup(each.value, "health_check_type", "")
  launch_template {
    id      = aws_launch_template.env_lt[lookup(each.value, "lt_resource_name", "")].id
    version = "$Latest"
  }
  tag {
    key                 = "name"
    value               = "${local.name_prefix}-${lookup(each.value, "asg_name", "")}-00"
    propagate_at_launch = true
  }
  lifecycle {
    ignore_changes = [target_group_arns]
  }
  depends_on = [aws_launch_template.env_lt]
}
# ----------------------------------------------------------------------------------------------------------------------
# Auto Scaling Group Attachment
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_attachment" "env_asg_attach" {
  for_each = { for key, value in var.asgs :
    key => value
  if lookup(value, "create_asg", false) == true }
  autoscaling_group_name = aws_autoscaling_group.env_asg[each.key].id
  lb_target_group_arn    = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn
  depends_on             = [aws_lb_target_group.env_alb_tg]
}
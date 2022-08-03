# ======================================================================================================================
# Autoscaling groups - ASG defined in asg.tfvars
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "asgs" {
  description = "A map of all autoscaling groups to create"
  default     = {}
}

variable "lts" {
  description = "A map of all launch templates to create"
  default     = {}
}



variable "cw_alarms" {
  description = "A map of the required CloudWatch alarms for instances"
  default     = {}
}

variable "instances" {
  description = "The number of instances. Used to assign tags to the asg"
  default     = 0
}

variable "account_hostname_prefix" {
  description = "The digit, x, that acts as a prefix to all instances in the account."
  default     = "X"
}

# ----------------------------------------------------------------------------------------------------------------------
# Launch Template
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "env_lt" {
  for_each = { for key, value in var.lts :
    key => value
  if lookup(value, "create_lt", false) == true }
  name                   = lookup(each.value, "lt_name", "")
  instance_type          = lookup(each.value, "instance_type", "")
  image_id               = lookup(each.value, "ami_id", "")
  user_data              = (lookup(each.value, "user_data", null) != null ? templatefile("${path.module}/${lookup(each.value, "user_data", "")}", {}) : null)
  key_name               = lookup(each.value, "ec2_account_key_name", "")
  vpc_security_group_ids = [for sg in lookup(each.value, "sg_names", []) : aws_security_group.ec2_sg[sg].id]

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
  vpc_zone_identifier       = [aws_subnet.env_subnet[element(lookup(each.value, "asg_subnets", ""), 0)].id, aws_subnet.env_subnet[element(lookup(each.value, "asg_subnets", ""), 1)].id, aws_subnet.env_subnet[element(lookup(each.value, "asg_subnets", ""), 2)].id]
  max_size                  = lookup(each.value, "asg_max_size", "")
  min_size                  = lookup(each.value, "asg_min_size", "")
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = lookup(each.value, "asg_desired_capacity", "")
  load_balancers            = [aws_lb.env_alb[lookup(each.value, "load_balancer", "")].name]

  launch_template {
  id      = aws_launch_template.env_lt[lookup(each.value, "lt_resource_name", "")].id   
  version = "$Latest"
  }
}
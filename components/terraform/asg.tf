/* # ======================================================================================================================
# Autoscaling Groups - ASG defined in asg.tfvars
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

variable "logstash_cw_alarms" {
  description = "A map of the required CloudWatch alarms for the logstash instances"
  default     = {}
}

variable "logstash_instances" {
  description = "The number of logstash instances. Used to assign tags to the asg"
  default     = 0
}

variable "account_hostname_prefix" {
  description = "The digit, x, that acts as a prefix to all instances in the account. AWSARVLx"
  default     = "X"
}

# ----------------------------------------------------------------------------------------------------------------------
# Launch Template
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_launch_template" "env_lt" {
  for_each      = var.lts
  name          = lookup(each.value, "lt_name", "")
  instance_type = lookup(each.value, "instance_type", "")
  image_id      = lookup(each.value, "ami_id", "")
  user_data     = base64encode(lookup(each.value, "user_data", null) != null ? templatefile("${path.module}/${lookup(each.value, "user_data", "")}", {}) : null)
  key_name      = "arv-host-svcs-kp"

  iam_instance_profile {
    name = lookup(each.value, "iam_instance_profile", "")
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg[element(lookup(each.value, "lt_sgs", ""), 0)].id]
    delete_on_termination       = lookup(each.value, "ni_del_on_termination", false)
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted   = true
      kms_key_id  = lookup(each.value, "root_kms_key", null) != null ? aws_kms_key.env_ebs_key[lookup(each.value, "root_kms_key", null)].arn : lookup(each.value, "root_kms_key_arn", null) != null ? lookup(each.value, "root_kms_key_arn", null) : null
      volume_size = lookup(each.value, "volume_size", "")
      volume_type = lookup(each.value, "volume_type", "")
    }
  }
} */
# ======================================================================================================================
# Basics of an EC2 instance and it's attached volumes
# ======================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "ec2s" {
  description = "A map of all ec2 istances. Each key in this map will have a value that is another map and it's this map that defines the ec2 characteristics"
  default     = {}
}

variable "ec2_ip_roles" {
  description = "A map of all resoures required to create an IAM instance role"
  default     = {}
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
resource "aws_instance" "instance_standard" {
  for_each = { for key, value in var.ec2s :
    key => value
  if lookup(value, "create_instance", false) == true }
  ami                         = lookup(each.value, "ami", "")
  instance_type               = lookup(each.value, "instance_type", "")
  subnet_id                   = element(aws_subnet.env_subnet.*.id, lookup(each.value, "subnet_number", ""))
  private_ip                  = lookup(each.value, "private_ip", "")
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  key_name                    = lookup(each.value, "ec2_account_key_name")
  vpc_security_group_ids      = lookup(each.value, "sg_names")
  iam_instance_profile        = lookup(each.value, "iam_instance_profile", "") == "" ? "" : "${lookup(each.value, "iam_instance_profile", "")}-iam-ip"
  disable_api_termination     = lookup(each.value, "disable_api_termination", null)
  monitoring                  = lookup(each.value, "monitoring", null)
  user_data                   = lookup(each.value, "user_data", null) != null ? templatefile("${path.module}/${lookup(each.value, "user_data", "")}", {}) : null

  tags = merge(
    local.default_tags,
    {

      "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = lookup(each.value, "tag_project", "")
    },
  )
}
# ===================================================================================================================
# Transit Gateway Attachments
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_tgw_atch" {
  description = "A flag used to control whether the attachment is created or not. True or false"
  default     = false
}

variable "atch_name" {
  description = "The string to use as a name tag for the attachement"
  default     = ""
}

variable "tgw_atch_subnet_ids" {
  description = "A list of subnet ids as defined in subnet.tfvars for the transit gateway attachments"
  default     = []
}

variable "tgw_default_rtbl" {
  description = "A flag whether the VPC Attachment should be associated and propagated with the EC2 Transit Gateway association default route table"
  default     = true
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
/* data "aws_ec2_transit_gateway" "mobilise_academy_tgw" {
  count = var.create_tgw_atch ? 1 : 0

  filter {
    name   = "options.amazon-side-asn"
    values = [var.transit_gateway_asn]
  }
} */
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

# cross account transit gateway attachment
/* resource "aws_ec2_transit_gateway_vpc_attachment" "x_act_tg_atmt" {
  count              = var.create_tgw_atch ? 1 : 0
  subnet_ids         = [for sn in var.tgw_atch_subnet_ids : aws_subnet.env_subnet[sn].id]
  transit_gateway_id = aws_ec2_transit_gateway.env_tgw[0].id
  vpc_id             = aws_vpc.env_vpc[0].id


  transit_gateway_default_route_table_association = var.tgw_default_rtbl
  transit_gateway_default_route_table_propagation = var.tgw_default_rtbl

  depends_on = [aws_subnet.env_subnet]
} */

data "aws_ec2_transit_gateway" "env_tgw" {
  count = var.create_tgw_atch ? 1 : 0
}

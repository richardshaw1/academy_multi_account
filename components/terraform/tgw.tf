# ===================================================================================================================
# Transit Gateway - Excluding the transit gateway attachments
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_tgw" {
  description = "A flag to include a transit gateway. true or false"
  default     = false
}

variable "create_tgw_local_vpc_amt" {
  description = "A flag to create a vpc attachment to the local VPC. true or false"
  default     = false
}

variable "tgw_local_vpc_att_sn_ids" {
  description = "A list of the subnet numbers (as defined in subnet.tfvars) for the local transit gateway VPC attachment"
  default     = []
}

variable "tgw_name_suffix" {
  description = "The transit gateway doesn't use the standard client-account as a name. Use this to ensure the name tag meets the design spec"
  default     = []
}

variable "ram_principals" {
  description = "A list of all the other accounts the transit gateway should share with"
  default     = []
}

variable "transit_gateway_asn" {
  description = "The asn of the transit gateway. Default is 64512."
  default     = ""
}

variable "tgw_routes" {
  description = "A map of all the transit gateway attachments and their cidr blocks"
  default     = {}
}

variable "tgw_vpc_attachments" {
  description = "A map of the VPC ids and the account names they belong to. Required for naming transit gateway attachments"
  default     = {}
}

variable "tgw_route_tables" {
  description = "A list of transit gateway route tables. Need to convert the list with toset for for_each to work"
  default     = []
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "env_tgw" {
  count                           = (var.create_tgw ? 1 : 0)
  description                     = "mobilise-academy-tgw"
  amazon_side_asn                 = var.transit_gateway_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    local.default_tags,
    {
      "Name" = "${var.client_abbr}-${var.tgw_name_suffix}"
    },
  )
}
# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Tables
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  for_each           = toset(var.tgw_route_tables)
  transit_gateway_id = aws_ec2_transit_gateway.env_tgw[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# The Local Transit Gateway VPC Attachment
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "public_to_vpc_b" {
  count              = var.create_tgw_local_vpc_amt ? 1 : 0
  subnet_ids         = [for sn in var.tgw_local_vpc_att_sn_ids : aws_subnet.env_subnet[sn].id]
  transit_gateway_id = aws_ec2_transit_gateway.env_tgw[count.index].id
  vpc_id             = aws_vpc.env_vpc[0].id

  transit_gateway_default_route_table_propagation = true
  transit_gateway_default_route_table_association = true
}

# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Tables Routes
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "tgw_local_vpc_route" {
  for_each = { for key, value in var.tgw_routes :
    key => value
  if lookup(value, "vpc_attachment", "") == "local" }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_to_vpc_b[0].id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[lookup(each.value, "tgw_route_table", "")].id
}
resource "aws_ec2_transit_gateway_route" "tgw_vpc_route" {
  for_each = { for key, value in var.tgw_routes :
    key => value
  if lookup(value, "vpc_attachment", "") != "local" && lookup(value, "vpc_attachment", "") != "" }
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[lookup(each.value, "tgw_route_table", "")].id
}

/* resource "aws_ec2_transit_gateway_route" "tgw_to_account_a" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.x_act_tg_atmt[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[lookup(each.value, "tgw_route_table", "")].id
} */

# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Table Associations & Propagations
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "tgw_local_vpc_rt_assoc" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_to_vpc_b[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table[var.environment].id
}
/* resource "aws_ec2_transit_gateway_route_table_association" "tgw_foreign_vpc" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.public_to_vpc_b[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.env_tgw[0].association_default_route_table_id
} */

# ----------------------------------------------------------------------------------------------------------------------
# Resource Access Management (RAM) resources
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "env_ram_share" {
  count                     = var.create_tgw ? 1 : 0
  name                      = "env_ram_share"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "env_ram_res_asoct" {
  count              = var.create_tgw ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.env_tgw[0].arn
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}

resource "aws_ram_principal_association" "ram_principal" {
  count              = length(var.ram_principals) < 0 ? 0 : length(var.ram_principals) * (var.create_tgw ? 1 : 0)
  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}
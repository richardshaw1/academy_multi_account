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
  default     = "64513"
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

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create the Transit Gateway attchments. As this is connecting the Transit Gateway to VPC subnets in separate
# accounts we need to create Resource Access Management resources
# ----------------------------------------------------------------------------------------------------------------------
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
  resource_arn       = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].arn
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}

resource "aws_ram_principal_association" "ram_principal" {
  count              = length(var.ram_principals) < 0 ? 0 : length(var.ram_principals) * (var.create_tgw ? 1 : 0)
  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}

# ----------------------------------------------------------------------------------------------------------------------
# Create Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "Mobilise_Academy_TGW" {
  count                          = var.create_tgw ? 1 : 0
  description                    = "Mobilise-Academy-TGW"
  amazon_side_asn                = var.transit_gateway_asn
  auto_accept_shared_attachments = "enable"

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
  transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# The Local Transit Gateway VPC Attachment
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "Public_to_VPC_B" {
  count              = var.create_tgw_local_vpc_amt ? 1 : 0
  subnet_ids         = [for sn in var.tgw_local_vpc_att_sn_ids : aws_subnet.env_subnet[sn].id] 
  transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  vpc_id             = aws_vpc.env_vpc[0].id

  transit_gateway_default_route_table_propagation = true
  transit_gateway_default_route_table_association = true
}
resource "aws_ec2_transit_gateway_route" "tgw_local_vpc_route" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Public_to_VPC_B[0].id
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].association_default_route_table_id
}
resource "aws_ec2_transit_gateway_route" "tgw_vpc_route" {
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Public_to_VPC_B[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "tgw_to_account_a" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.x_act_tg_atmt[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].association_default_route_table_id
}

# ----------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Table Associations & Propagations
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table_association" "tgw_vpn_rt_assoc" {
  for_each                       = var.vpn_connections
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.env_tg_vpn_attmts[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[lookup(each.value, "tgw_rt_tbl", "")].id
}

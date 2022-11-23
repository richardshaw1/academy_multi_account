# ===================================================================================================================
# Transit Gateway
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "get_tgw_id" {
  type        = bool
  description = "get transit gateway id"
  default     = false
}
variable "get_tgw_x_id" {
  type        = bool
  description = "get transit gateway id"
  default     = false
}
variable "create_tgw" {
  type        = bool
  description = "Whether to include a transit gateway"
  default     = false
}

variable "transit_gateway_asn" {
  description = "The asn of the transit gateway"
  default     = "64515"
}


variable "tgw_name_suffix" {
  description = "suffix for the name of the Transit Gateway"
  default     = "tgw"
}

variable "create_tgw_local_vpc_amt" {
  description = "flag to create a vpc attachment to the local VPC. true or false"
  default     = false
}

variable "tgw_local_atch_name" {
  type        = string
  description = "name of the local Transit Gateway attachment"
  default     = ""
}

variable "tgw_local_routes" {
  type        = map(any)
  description = "map of tgw local routes"
  default     = {}
}

variable "tgw_routes" {
  type        = map(any)
  description = "map of tgw routes"
  default     = {}
}

variable "tgw_route_tables" {
  type        = list(any)
  description = "a list of transit gateway route tables"
  default     = []
}

variable "tgw_local_vpc_att_sn_ids" {
  description = "list of the subnet numbers (as defined in subnet.tfvars) for the local transit gateway VPC attachment"
  default     = []
}
variable "create_tgw_route_table" {
  type        = bool
  description = "creates tgw route table"
  default     = false
}

variable "create_tgw_x_act_amt" {
  type        = bool
  description = "A flag to create a vpc attachment to the local vpc. true or false"
  default     = false
}

variable "tgw_x_act_amt_name" {
  description = "A flag to create a vpc attachment to the local vpc. true or false"
  default     = ""
}

variable "tgw_x_act_routes" {
  type        = map(any)
  description = "map of transit gateway cross account routes"
  default     = {}
}

variable "tgw_x_act_atch_subnets" {
  description = "list of subnet ids as defined in subnet.tfvars for the cross account transit gateway attachments"
  default     = []
}

variable "tgw_id_filter_name" {
  type        = string
  description = "transit gateway id filter name"
  default     = ""
}

variable "tgw_default_route_table_association" {
  type        = bool
  description = "transit gateway default route table association"
  default     = false
}
variable "tgw_default_route_table_propagation" {
  type        = bool
  description = "transit gateway default route table propagation"
  default     = false
}
variable "default_route_table_association" {
  type        = string
  description = "transit gateway default route table association"
  default     = ""
}
variable "default_route_table_propagation" {
  type        = string
  description = "transit gateway default route table propagation"
  default     = ""
}
variable "tgw_vpc_attachments" {
  type        = map(any)
  description = "a map of transit gateway cross account attachment vpc ids"
  default     = {}
}
variable "tgw_x_filter_name" {
  type        = string
  description = "transit gateway cross account attachment filter name"
  default     = ""
}

variable "auto_accept" {
  type        = string
  description = "auto accept shared attachments"
  default     = ""
}
# =========================================================================================================================
# transit gateway data block
# =========================================================================================================================
data "aws_ec2_transit_gateway" "env_transit_gateway" {
  count = var.get_tgw_id ? 1 : 0
  filter {
    name   = var.tgw_id_filter_name
    values = [var.transit_gateway_asn]
  }
}
data "aws_ec2_transit_gateway_vpc_attachment" "env_transit_gateway_x_attach" {
  for_each = var.tgw_vpc_attachments
  filter {
    name   = var.tgw_x_filter_name
    values = [each.value]
  }
}
# ----------------------------------------------------------------------------------------------------------------------
# Create Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "env_tgw" {
  count                           = var.create_tgw ? 1 : 0
  description                     = "mobilise-academy-tgw"
  amazon_side_asn                 = var.transit_gateway_asn
  auto_accept_shared_attachments  = var.auto_accept
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(
    local.default_tags,
    {
      "Name" = "${var.client_abbr}-${var.tgw_name_suffix}"
    },
  )
  lifecycle {
    ignore_changes = [default_route_table_association, default_route_table_propagation]
  }

}

# -------------------------------------------------------------------------------------------------------------------------
# transit gateway route table
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route_table" "env_tgw_rtbl" {
  count              = var.create_tgw_route_table ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.env_tgw[0].id
  tags = merge(
    local.default_tags,
    {
      "Name" = "${var.client_abbr}-tgw-rtbl"
    },
  )
  depends_on = [aws_ec2_transit_gateway.env_tgw]
}

# ----------------------------------------------------------------------------------------------------------------------
# The Local Transit Gateway Local VPC Attachment to Account B
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "env_tgw_attach" {
  count                                           = var.create_tgw_local_vpc_amt ? 1 : 0
  subnet_ids                                      = [for sn in var.tgw_local_vpc_att_sn_ids : aws_subnet.env_subnet[sn].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.env_tgw[0].id
  vpc_id                                          = aws_vpc.env_vpc[0].id
  transit_gateway_default_route_table_association = var.tgw_default_route_table_association
  transit_gateway_default_route_table_propagation = var.tgw_default_route_table_propagation
  depends_on                                      = [aws_subnet.env_subnet]

  tags = merge(
    local.default_tags,
    {
      "Name" = var.tgw_local_atch_name
    },
  )
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "env_tgw_rtbl_assoc" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tgw_attach[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "env_tgw_rtbl_prop" {
  count                          = var.create_tgw_local_vpc_amt ? 1 : 0
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tgw_attach[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}



# ----------------------------------------------------------------------------------------------------------------------
# The Cross-Account VPC Attachment to Account B
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_x_act_amt" {
  count                                           = (var.create_tgw_x_act_amt ? 1 : 0) * (var.get_tgw_id ? 1 : 0)
  subnet_ids                                      = [for sn in var.tgw_x_act_atch_subnets : aws_subnet.env_subnet[sn].id]
  transit_gateway_id                              = data.aws_ec2_transit_gateway.env_transit_gateway[0].id
  vpc_id                                          = aws_vpc.env_vpc[0].id
  transit_gateway_default_route_table_association = var.tgw_default_route_table_association
  transit_gateway_default_route_table_propagation = var.tgw_default_route_table_propagation
  depends_on                                      = [aws_subnet.env_subnet]
  tags = merge(
    local.default_tags,
    {
      "Name" = var.tgw_x_act_amt_name
    },
  )
  lifecycle {
    ignore_changes = [transit_gateway_default_route_table_association, transit_gateway_default_route_table_propagation]
  }

}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_x_ra" {
  for_each                       = var.tgw_vpc_attachments
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.env_transit_gateway_x_attach[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_x_rp" {
  for_each                       = var.tgw_vpc_attachments
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpc_attachment.env_transit_gateway_x_attach[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}

# -------------------------------------------------------------------------------------------------------------------------
# Transit Gateway Routes
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_route" "tgw_routes" {
  for_each = { for key, value in var.tgw_local_routes :
    key => value
  if lookup(value, "vpc_attachment", "") == "local" }
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.env_tgw_attach[0].id
  destination_cidr_block         = lookup(each.value, "destination_cidr_block", "")
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.env_tgw_rtbl[0].id
}


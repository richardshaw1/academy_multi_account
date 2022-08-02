# ===================================================================================================================
# Route Tables Variables
# ===================================================================================================================
variable "get_tgw_id" {
  description = "to create or not to create a route to the transit gateway"
  default     = false
}

variable "igw_subnets" {
  description = "List of the subnets that require a route through the internet gateway."
  default     = []
}

variable "ngw_subnets" {
  description = "List of the subnets that require a route through the NAT gateway."
  default     = []
}

variable "tgw_igw_subnets" {
  description = "List of subnets that want to pass all traffic (0.0.0.0/0) through the transit gateway"
  default     = []
}

variable "create_rtbl" {
  description = "Creates VPC subnet Route Tables"
  default     = false
}

variable "create_rt" {
  description = "Creates Route"
  default     = false
}

variable "tgw_account_b_subnets" {
  description = "List of subnets that we want to route to account-b via the transit gateway"
  default     = []
}

variable "tgw_account_a_subnets" {
  description = "List of subnets to route to account-a via the transit gateway"
  default     = []
}

variable "tgw_subnets" {
  description = "List of subnets to route to the internet via the transit gateway"
  default     = []
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route Table
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "env_rt_tbl" {
  count  = (var.create_rtbl ? 1 : 0) * length(var.subnet_names)
  vpc_id = aws_vpc.env_vpc[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-public-rtbl-${substr(var.environment_azs[count.index], -1, -1)}"
    }
  )
}

# ======================================================================================================================
# ROUTES - Account A
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Subnets to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_to_internet" {
  /* count                  = length(var.igw_subnets) * (var.get_tgw_id ? 1 : 0) */
  count                  = (var.create_rt ? 1 : 0) * length(var.igw_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Subnets to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_to_vpc_b" {
  count                  = length(var.tgw_account_b_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = local.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

# ----------------------------------------------------------------------------------------------------------------------
# Route: Direct Traffic via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_to_internet" {
  count                  = length(var.tgw_igw_subnets)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnets to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_01_to_vpc_b" {
  count                  = length(var.tgw_account_b_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = local.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

# ======================================================================================================================
# ROUTES - Account B
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnets (APP & DATA) to Internet via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_to_internet" {
  count                  = (var.create_rt ? 1 : 0) * length(var.tgw_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (APP & DATA) 01 to Account-A via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_to_vpc_a" {
  count                  = (var.create_rt ? 1 : 0) * length(var.tgw_account_a_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = local.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

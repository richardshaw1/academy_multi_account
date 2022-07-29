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

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route Table
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route_table" "env_rt_tbl" {
  count  = length(var.subnet_names)
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
# Route: Public Subnet 01 to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_01_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Subnet 01 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_01_to_vpc_b" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.1.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Subnet 02 to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_02_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Subnet 02 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "pub_sub_02_to_vpc_b" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.1.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: NAT Gateway Subnet 01 to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "ngw_sub_01_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: NAT Gateway Subnet 01 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "ngw_sub_01_to_vpc_b" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.1.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnet 01 to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_01_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnet 01 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_01_to_vpc_b" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.1.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnet 02 to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_02_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnet 02 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_02_to_vpc_b" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.1.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ======================================================================================================================
# ROUTES - Account B
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (APP) 01 to Internet via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_app_01_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (APP) 01 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_app_01_to_vpc_a" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.0.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (APP) 02 to Internet via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_app_02_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (APP) 02 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_app_02_to_vpc_a" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.0.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (DATA)) 01 to Internet via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_data_01_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (DATA) 01 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_data_01_to_vpc_a" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.0.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (DATA) 02 to Internet via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_data_02_to_internet" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Private Subnet (DATA) 02 to Account-B via Transit Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_data_02_to_vpc_a" {
  count                  = var.create_rt ? 1 : 0
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "10.0.0.0/16"
  gateway_id             = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
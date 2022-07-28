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
# public subnet Route Tables (deployed in each AZ)
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

# ----------------------------------------------------------------------------------------------------------------------
# Route: Internet traffic goes to the NGW located in the public subnet
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "service_to_ngw_internet_rt" {
  count                  = (var.create_rtbl ? 1 : 0) * length(var.ngw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.ngw_subnets, count.index))
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.env_ngw[0].id
}
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
  gateway_id             = aws_transit_gateway.env_tgw[0].id
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
  gateway_id             = aws_transit_gateway.env_tgw[0].id
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
  gateway_id             = aws_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: direct internal traffic to the VPC-A (account-A) via the transit gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env_route_to_account_a" {
  count                  = length(var.tgw_account_b_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = local.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl, aws_ec2_transit_gateway.env_tgw]
}
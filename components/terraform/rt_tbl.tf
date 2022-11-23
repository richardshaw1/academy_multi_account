# ===================================================================================================================
# Route Tables Variables
# ===================================================================================================================
variable "create_rtbl" {
  type        = bool
  description = "creates route table"
  default     = false
}

variable "create_route" {
  type        = bool
  description = "creates route"
  default     = false
}

variable "igw_subnets" {
  type        = list(any)
  description = "List of the subnets that require a route through the internet gateway."
  default     = []
}

variable "ngw_subnets" {
  type        = list(any)
  description = "List of the subnets that require a route through the NAT gateway."
  default     = []
}

variable "tgw_subnets" {
  type        = list(any)
  description = "List of subnets that want to pass all traffic (0.0.0.0/0) through the transit gateway"
  default     = []
}

variable "private_subnets" {
  type        = list(any)
  description = "List of subnets that want to pass all traffic (0.0.0.0/0) through the transit gateway"
  default     = []
}
variable "tgw_vpc_a_subnets" {
  description = "List of subnets to route to the internet via the transit gateway"
  default     = []
}

variable "tgw_vpc_b_subnets" {
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
      "Name" = "${var.subnet_names[count.index]}-rt"
    }
  )
}

resource "aws_route_table" "tgw_vpc_a_rtbl" {
  count  = (var.create_rtbl ? 1 : 0) * length(var.subnet_names)
  vpc_id = aws_vpc.env_vpc[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-public-rtbl-${substr(var.environment_azs[count.index], -1, -1)}"
    }
  )
}

resource "aws_route_table" "tgw_vpc_b_rtbl" {
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
# Route Table Association - Associate subnets with the Route Table
# ======================================================================================================================
resource "aws_route_table_association" "rt_bl_asocn" {
  count          = (var.create_rtbl ? 1 : 0) * length(keys(var.subnet_names))
  subnet_id      = aws_subnet.env_subnet[count.index].id
  route_table_id = element(aws_route_table.env_rt_tbl.*.id, count.index)
}


# ======================================================================================================================
# ROUTES - Account A
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route: Direct Traffic to Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "igw_route" {
  count                  = (var.create_route ? 1 : 0) * length(var.igw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.igw_subnets, count.index))
  destination_cidr_block = local.internet_cidr
  gateway_id             = aws_internet_gateway.env_igw[0].id
  depends_on             = [aws_internet_gateway.env_igw]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Public Route to VPC-B
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_route" {
  count                  = length(var.tgw_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

# ----------------------------------------------------------------------------------------------------------------------
# Route: Direct Traffic via NAT Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "ngw_route" {
  count                  = length(var.ngw_subnets)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.env_ngw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

# ----------------------------------------------------------------------------------------------------------------------
# Route: Direct Traffic to VPC B via Transit Gateway 
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_route_vpc_b" {
  count                  = length(var.tgw_subnets)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}

# ----------------------------------------------------------------------------------------------------------------------
# Route: Direct Traffic to VPC A via Transit Gateway 
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env_route_to_vpc_a" {
  count                  = length(var.tgw_subnets)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_route_table.env_rt_tbl]
}
# ----------------------------------------------------------------------------------------------------------------------
# Route: Transit Gateway Subnets to Account-B via Transit Gateway
/* # ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_sub_01_to_vpc_b" {
  count                  = length(var.tgw_account_b_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = aws_route_table.env_rt_tbl[count.index].id
  }
resource "aws_route" "pub_to_vpc_b" {
  count                  = (var.create_route ? 1 : 0) * length(var.igw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.igw_subnets, count.index))
  destination_cidr_block = local.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_ec2_transit_gateway.env_tgw]
}
# -------------------------------------------------------------------------------------------------------------------------
# route: TGW route to internet
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_to_internet" {
  count                  = (var.create_route ? 1 : 0) * length(var.tgw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.tgw_subnets, count.index))
  destination_cidr_block = local.internet_cidr
  nat_gateway_id         = aws_nat_gateway.env_ngw[0].id
  depends_on             = [aws_nat_gateway.env_ngw]
}
# -------------------------------------------------------------------------------------------------------------------------
# route: tgw route to vpc-b
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "tgw_to_vpc_b" {
  count                  = (var.create_route ? 1 : 0) * length(var.tgw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.tgw_subnets, count.index))
  destination_cidr_block = local.vpc_b_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.env_tgw[0].id
  depends_on             = [aws_ec2_transit_gateway.env_tgw]
}
# -------------------------------------------------------------------------------------------------------------------------
# route: private route to internet
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_to_internet" {
  count                  = (var.create_route ? 1 : 0) * length(var.private_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.private_subnets, count.index))
  destination_cidr_block = local.internet_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.env_transit_gateway[0].id
  depends_on             = [aws_ec2_transit_gateway.env_tgw]
}
# -------------------------------------------------------------------------------------------------------------------------
# route: private route to vpc-b
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_route" "priv_sub_to_vpc_b" {
  count                  = (var.create_route ? 1 : 0) * length(var.private_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.private_subnets, count.index))
  destination_cidr_block = local.vpc_a_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.env_transit_gateway[0].id
  depends_on             = [aws_ec2_transit_gateway.env_tgw]
} */
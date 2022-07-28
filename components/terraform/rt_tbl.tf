# ===================================================================================================================
# Route Tables
# ===================================================================================================================
variable "get_tgw_id" {
  description = "to create or not to create a route to the transit gateway"
  default     = false
}

variable "shared_transit_gateway_id" {
  description = "This is hard-coded for now, but we should incorporate data-lookups once we find a way to effectively do cross-account data-lookups"
  default     = ""
}

variable "add_tgw_rules_to_ff_rtb" {
  description = ""
  default     = []
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
# Public subnet Route Tables (deployed in each AZ)
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
# Create a route table for the service private subnets
# ----------------------------------------------------------------------------------------------------------------------
/* 
resource "aws_route_table" "service_rtbl" {
  count  = (var.create_rtbl ? 1 : 0) * length(var.environment_azs)
  vpc_id = aws_vpc.env_vpc[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-service-priv-subnet-rtbl-${substr(var.environment_azs[count.index], -1, -1)}"
    }
  )
} */

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
# Route: direct all traffic to the Internet Gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "public_rt" {
  count                  = length(var.igw_subnets)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.igw_subnets, count.index))
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.env_igw[0].id
}

# ----------------------------------------------------------------------------------------------------------------------
# Route: direct internal traffic to the VPC-A (account-A) via the transit gateway
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_route" "env_route_to_account_a" {
  count                  = length(var.tgw_account_b_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = "env_rt_tbl"
  destination_cidr_block = local.vpc_a_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  depends_on             = [aws_route_table.env_rt_tbl, aws_ec2_transit_gateway.Mobilise_Academy_TGW]
}

# ===================================================================================================================
# Resource Creation
# ===================================================================================================================
# ===================================================================================================================
# Route Tables
# ===================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Account A Route Tables
# ----------------------------------------------------------------------------------------------------------------------
/* resource "aws_default_route_table" "r" {
  count                  = var.create_vpc ? 1 : 0
  default_route_table_id = aws_vpc.env_vpc[0].default_route_table_id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-main-rtbl"
    },
  )

  lifecycle {
    ignore_changes = [
      tags["DeployedBy"], tags["Branch"], tags["InitDeployDate"]
    ]
  }
}

# Created on the premise that each subnet created will be assigned its own individual route table.
resource "aws_route_table" "env_rt_tbl" {
  count  = length(var.subnet_names)
  vpc_id = aws_vpc.env_vpc[0].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-${var.subnet_names[count.index]}-${substr(var.environment_azs[count.index], -1, -1)}-rtbl"
    },
  )

  lifecycle {
    ignore_changes = [
      tags["DeployedBy"], tags["Branch"], tags["InitDeployDate"]
    ]
  }
} */


/* resource "aws_route_table" "subnet_01_rt" {
  vpc_id = aws_vpc.env_vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.env_igw[0].id
  }
  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  }

  tags = {
    Name  = "Public-Subnet-01-RT"
    Owner = "MobiliseAcademy-rs"
  }
}

resource "aws_route_table" "subnet_02_rt" {
  vpc_id = aws_vpc.env_vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.env_igw[0].id
  }
  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  }

  tags = {
    Name  = "Public-Subnet-02-RT"
    Owner = "MobiliseAcademy-rs"
  }
}

resource "aws_route_table" "tgw_a_rt" {
  vpc_id = aws_vpc.env_vpc[0].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.env_ngw.id
  }
  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  }

  tags = {
    Name  = "tgw-a-rt"
    Owner = "MobiliseAcademy-rs"
  }
}

resource "aws_route_table" "tgw_b_rt" {
  vpc_id = aws_vpc.env_vpc[0].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.env_ngw[0].id
  }
  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  }

  tags = {
    Name  = "tgw-b-rt"
    Owner = "MobiliseAcademy-rs"
  }
}

resource "aws_route_table" "nat_subnet_01_rt" {
  vpc_id = aws_vpc.env_vpc[0].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.env_igw[0].id
  }
  route {
    cidr_block         = "10.1.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.Mobilise_Academy_TGW[0].id
  }

  tags = {
    Name  = "nat-gw-01-rt"
    Owner = "MobiliseAcademy-rs"
  }
} */


# ===================================================================================================================
# Routes
# ===================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Route: direct internal traffic to the account-B via the transit gateway
# ----------------------------------------------------------------------------------------------------------------------
/* resource "aws_route" "env_route_to_prod_svcs" {
  count                  = length(var.tgw_prod_subnets) * (var.get_tgw_id ? 1 : 0)
  route_table_id         = element(aws_route_table.env_rt_tbl.*.id, element(var.tgw_prod_subnets, count.index))
  destination_cidr_block = local.prod_acc_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.main_transit_gateway[0].id
  depends_on             = [aws_route_table.env_rt_tbl, aws_ec2_transit_gateway.env_tgw]
} */

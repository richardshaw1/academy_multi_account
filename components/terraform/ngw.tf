# ===================================================================================================================
# NAT Gateway
# ===================================================================================================================
# ======================================================================================================================
# Variables
# ======================================================================================================================

variable "create_ngw" {
  description = "Creates NAT Gateway"
  default     = false
}

variable "ngw_att_subnets" {
  description = "List of the subnets that require a NAT gateway to be associated with them."
  default     = []
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create Elastic IP and assign tags
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "env_ngw_eip" {
  count = length(var.ngw_att_subnets)
  vpc   = true

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-ngw-eip-${substr(var.environment_azs[count.index], -1, -1)}"
    }
  )
  depends_on = [aws_internet_gateway.env_igw]
}

# ----------------------------------------------------------------------------------------------------------------------
# Create the NGW
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_nat_gateway" "env_ngw" {
  count         = length(var.ngw_att_subnets)
  allocation_id = aws_eip.env_ngw_eip[count.index].id
  subnet_id     = aws_subnet.env_subnet[element(var.ngw_att_subnets, count.index)].id

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-ngw-${substr(var.environment_azs[count.index], -1, -1)}"
    }
  )
  depends_on = [aws_internet_gateway.env_igw]
}
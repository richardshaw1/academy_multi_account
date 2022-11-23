# ======================================================================================================================
# SUBNETS
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "subnet_cidrs" {
  type        = map(any)
  description = "Map of the CIDR ranges used for each subnet."
  default     = {}
}

variable "subnet_names" {
  description = "Map of public subnet names"
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# RESOURCE CREATION
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_subnet" "env_subnet" {
  count             = length(var.subnet_names)
  vpc_id            = aws_vpc.env_vpc[0].id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = "${var.region_name}${var.environment_azs[count.index]}"

  tags = merge(
    local.default_tags,
    {
      "Name" = "${local.name_prefix}-subnet-${substr(var.environment_azs[count.index], -1, -1)}"

    }
  )
}
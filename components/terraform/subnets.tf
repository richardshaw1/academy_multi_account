# ======================================================================================================================
# SUBNETS
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_subnets" {
  description = "Creates VPC Subnets"
  default     = false
}

variable "subnet_cidrs" {
  type        = map(any)
  description = "Map of the CIDR ranges used for each subnet."
  default     = {}
}

variable "private_subnet_cidrs" {
  type        = map(any)
  description = "Map of the CIDR ranges used for each subnet."
  default     = {}
}

variable "subnet_tags" {
  description = "A map of tags to apply to each subnet"
  default     = {}
}

variable "subnet_names" {
  description = "Map list of the names to give to the individual subnets. These can then be referenced by route tables"
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
      "CIDRRange" = var.subnet_cidrs[count.index]
      "Name"      = "${local.name_prefix}-${var.subnet_names[count.index]}-${substr(var.environment_azs[count.index], -1, -1)}"
      "Owner"     = "mobilise-academy"
      "Project"   = "workshop"
      "VPC"       = aws_vpc.env_vpc[0].id
    },
  )
}
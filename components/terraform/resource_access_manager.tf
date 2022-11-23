# -------------------------------------------------------------------------------------------------------------------------
# Resource Access Managener
# -------------------------------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------------------------------
variable "create_share" {
  type        = bool
  description = "create share"
  default     = false
}

variable "ram_name" {
  type        = string
  description = "name of the resource access manager"
  default     = ""
}

variable "ram_principal" {
  type        = string
  description = "principal for resource access manager sharing"
  default     = ""
}

# -------------------------------------------------------------------------------------------------------------------------
# Resource Creation
# -------------------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "tgw_share_rs" {
  count                     = var.create_tgw ? 1 : 0
  name                      = var.ram_name
  allow_external_principals = true
  depends_on                = [aws_ec2_transit_gateway.env_tgw]

  tags = merge(
    local.default_tags,
    {
      "Name" = var.ram_name
    },
  )
}
resource "aws_ram_resource_association" "tgw_share_ra" {
  count              = var.create_share ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.env_tgw[0].arn
  resource_share_arn = aws_ram_resource_share.tgw_share_rs[0].arn
}
resource "aws_ram_principal_association" "tgw_share_pa" {
  count              = var.create_share ? 1 : 0
  principal          = var.ram_principal
  resource_share_arn = aws_ram_resource_share.tgw_share_rs[0].arn
}


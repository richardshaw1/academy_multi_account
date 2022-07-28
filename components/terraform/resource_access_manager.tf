# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
#  As this is connecting the Transit Gateway to VPC subnets in separate
# accounts we need to create Resource Access Management resources
# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------
# Resource Access Management (RAM) resources
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_ram_resource_share" "env_ram_share" {
  count                     = var.create_tgw ? 1 : 0
  name                      = "env_ram_share"
  allow_external_principals = true
}

resource "aws_ram_resource_association" "env_ram_res_asoct" {
  count              = var.create_tgw ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.mobilise_academy_tgw[0].arn
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}

resource "aws_ram_principal_association" "ram_principal" {
  count              = length(var.ram_principals) < 0 ? 0 : length(var.ram_principals) * (var.create_tgw ? 1 : 0)
  principal          = var.ram_principals[count.index]
  resource_share_arn = aws_ram_resource_share.env_ram_share[0].arn
}
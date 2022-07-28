# -------------------------------------------------------------------------------------------------------------------
# Transit Gateway Specific Variables
# -------------------------------------------------------------------------------------------------------------------
create_tgw_atch     = true
transit_gateway_asn = "64514"
atch_name           = "public-to-VPC-B"
tgw_atch_subnet_ids = ["3", "4"]
tgw_default_rtbl    = false
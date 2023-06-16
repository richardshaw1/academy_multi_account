# -------------------------------------------------------------------------------------------------------------------
# Transit Gateway Specific Variables
# -------------------------------------------------------------------------------------------------------------------
create_tgw                          = true
create_tgw_local_vpc_amt            = true
create_tgw_route_table              = true
create_share                        = true
auto_accept                         = "enable"
tgw_local_vpc_att_sn_ids            = ["3", "4"]
tgw_local_atch_name                 = "public-to-vpc-b"
ram_principal                       = "226283484947"
default_route_table_association     = "disable"
default_route_table_propagation     = "disable"
tgw_default_route_table_association = false
tgw_default_route_table_propagation = false
transit_gateway_asn                 = "64515"
tgw_x_filter_name                   = "vpc-id"
ram_name                            = "academy-resource-share"

tgw_vpc_attachments = {
  "account-b" = "vpc-0b919059bbec3d6ae"
}

tgw_local_routes = {
  "tgw_to_internet" = {
    "vpc_attachment"         = "local"
    "destination_cidr_block" = "0.0.0.0/0"
  }
}

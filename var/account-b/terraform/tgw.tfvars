# ======================================================================================================================
# Transit Gateway variables
# ======================================================================================================================
create_tgw                          = false
create_tgw_local_vpc_amt            = false
create_tgw_route_table              = false
create_share                        = false
tgw_default_route_table_association = false
tgw_default_route_table_propagation = false
create_tgw_x_act_amt                = true
tgw_x_act_atch_subnets              = ["0", "1"]
transit_gateway_asn                 = "64515"
get_tgw_id                          = true
tgw_x_act_amt_name                  = "private-to-vpc-a"
tgw_id_filter_name                  = "options.amazon-side-asn"

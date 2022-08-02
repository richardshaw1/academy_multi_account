# -------------------------------------------------------------------------------------------------------------------
# Transit Gateway Specific Variables - 
# -------------------------------------------------------------------------------------------------------------------
create_tgw               = true
create_tgw_local_vpc_amt = true
create_tgw_route_table   = true
tgw_local_vpc_att_sn_ids = ["3", "4"]
tgw_name_suffix          = "transit-tgw"
transit_gateway_asn      = "64514"
ram_principals           = ["226283484947", "784943245565"]

# Transit Gateway Route Tables
tgw_route_tables = [
  "account-A",
  "account-B"
]

# These keys must match a value in tgw_route_tables
tgw_vpc_attachments = {
  "account-A" = "vpc-09b9326f37ef9a25b",
  "account-B" = "vpc-0e905761fee69b3ea"
}

tgw_routes = {
  "vpc_a_local" = {
    "vpc_attachment"         = "local"
    "destination_cidr_block" = "10.0.0.0/16"
    "tgw_route_table"        = "account-A"
  }
  "vpc_a_vpc_b" = {
    "vpc_attachment"         = "VPC-A"
    "destination_cidr_block" = "10.1.0.0/16"
    "tgw_route_table"        = "account-A"
  }
  "vpc_a_ngw" = {
    "vpc_attachment"         = "VPC-A"
    "destination_cidr_block" = "10.1.0.0/16"
    "tgw_route_table"        = "account-A"
  }
  "vpc_b_local" = {
    "vpc_attachment"         = "local"
    "destination_cidr_block" = "10.0.0.0/16"
    "tgw_route_table"        = "account-B"
  }
  "vpc_b_vpc_a" = {
    "vpc_attachment"         = "VPC-B"
    "destination_cidr_block" = "10.1.0.0/16"
    "tgw_route_table"        = "account-B"
  }
}
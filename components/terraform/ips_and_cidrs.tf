# ===================================================================================================================
# GETTING THE NECESSARY VARIABLES FOR THE SECURITY GROUP RULES
# ===================================================================================================================
# ===================================================================================================================
# LOCAL VARIABLES
# ===================================================================================================================
locals {
  vpc_a_cidr                = "10.0.0.0/16"   # The CIDR range for VPC-A
  vpc_b_cidr                = "10.1.0.0/16"   # The CIDR range for VPC-B
  vpc_a_squid_a_sn_cidr     = "10.0.0.0/27"   # The CIDR range for the VPC-A Public-subnet-01
  vpc_a_squid_b_sn_cidr     = "10.0.0.32/27"  # The CIDR range for the VPC-A public-subnet-02
  vpc_a_nat_sn_cidr         = "10.0.0.64/27"  # The CIDR range for the VPC-A public-subnet-(NAT)
  vpc_a_tgw_a_sn_cidr       = "10.0.0.96/27"  # The CIDR range for the VPC-A TGW-A-subnet
  vpc_a_tgw_b_sn_cidr       = "10.0.0.128/27" # The CIDR range for the VPC-A TGW-B-subnet
  vpc_b_priv_app_a_sn_cidr  = "10.1.0.0/27"   # The CIDR range for the VPC-B Private-App-01-subnet
  vpc_b_priv_app_b_sn_cidr  = "10.1.0.32/27"  # The CIDR range for the VPC-B Private-App-02-subnet
  vpc_b_priv_data_a_sn_cidr = "10.1.0.64/27"  # The CIDR range for the VPC-B Private-Data-01-subnet
  vpc_b_priv_data_b_sn_cidr = "10.1.0.96/27"  # The CIDR range for the VPC-B Private-Data-02-subnet
}
# ----------------------------------------------------------------------------------------------------------------------
# Subnet Specific Variables
# ----------------------------------------------------------------------------------------------------------------------
subnet_names = {
  # Public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "Public-Subnet-01"
  "1" = "Public-Subnet-02"
  # Public Subnet for NAT Gateway
  "2" = "Public-Subnet-(NAT)"
  # Public Subnets for Transit Gateway
  "3" = "TGW-A"
  "4" = "TGW-B"
}
environment_azs = {
  # Public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "a"
  "1" = "b"
  # Public Subnet for NAT Gateway
  "2" = "a"
  # Public Subnets for Transit Gateway
  "3" = "a"
  "4" = "b"
}
subnet_cidrs = {
  # Public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "10.0.0.0/27"
  "1" = "10.0.0.32/27"
  # Public Subnet for NAT Gateway
  "2" = "10.0.0.64/27"
  # Public Subnets for Transit Gateway
  "3" = "10.0.0.96/27"
  "4" = "10.0.0.128/27"
}

# Name, Owner
subnet_tags = {
  "0" = [""]
  "1" = [""]
  "2" = [""]
  "3" = [""]
  "4" = [""]
}


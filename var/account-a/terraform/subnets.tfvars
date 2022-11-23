# ----------------------------------------------------------------------------------------------------------------------
# Subnet Specific Variables
# ----------------------------------------------------------------------------------------------------------------------
subnet_names = {
  # public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "public-Subnet-01"
  "1" = "public-Subnet-02"
  # public Subnet for NAT Gateway
  "2" = "public-Subnet-(NAT)"
  # public Subnets for Transit Gateway
  "3" = "tgw-A"
  "4" = "tgw-B"
}

subnet_cidrs = {
  # public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "10.2.0.0/27"
  "1" = "10.2.0.32/27"
  # public Subnet for NAT Gateway
  "2" = "10.2.0.64/27"
  # public Subnets for Transit Gateway
  "3" = "10.2.0.96/27"
  "4" = "10.2.0.128/27"
}

environment_azs = {
  # public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "a"
  "1" = "b"
  # public Subnet for NAT Gateway
  "2" = "a"
  # public Subnets for Transit Gateway
  "3" = "a"
  "4" = "b"
<<<<<<< HEAD
  "5" = "c"
}
subnet_cidrs = {
  # public Subnets for EC2 Squid Proxies + Bastion Host
  "0" = "10.0.0.0/27"
  "1" = "10.0.0.32/27"
  # public Subnet for NAT Gateway
  "2" = "10.0.0.64/27"
  # public Subnets for Transit Gateway
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

=======
}
>>>>>>> origin/main

# ----------------------------------------------------------------------------------------------------------------------
# Subnet Specific Variables
# ----------------------------------------------------------------------------------------------------------------------

subnet_names = {
  "private_subnets" = {
    # Private APP Subnets for Wordpress EC2
    "0" = "private-subnet-(APP)-01"
    "1" = "private-subnet-(APP)-02"
    # Private DATA Subnets for Databases
    "2" = "private-subnet-(DATA)-01"
    "3" = "private-subnet-(DATA)-02"
  }
}

private_subnet_cidrs = {
  # Private APP Subnets for Wordpress EC2
  "0" = "10.1.0.0/27"
  "1" = "10.1.32/27"
  # Private DATA Subnets for Databases
  "2" = "10.1.64/27"
  "3" = "10.1.96/27"
}

environment_azs = {
  # Private APP Subnets for Wordpress EC2
  "0" = "a"
  "1" = "b"
  # Private DATA Subnets for Databases
  "2" = "a"
  "3" = "b"
}

subnet_tags = {
  "0" = ""
  "1" = ""
  "2" = ""
  "3" = ""
}
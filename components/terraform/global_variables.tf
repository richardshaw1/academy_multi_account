variable "account_no" {
  type        = string
  description = "AWS Account No"
}

variable "owner" {
  type        = string
  description = "The Owner of the environment e.g mobilise"
  default     = "mobilise-academy"
}

variable "project" {
  type        = string
  description = "Name of the project being deployed"
  default     = "workshop"
}

variable "client_abbr" {
  type        = string
  description = "Abbreviated name of the client e.g mobilise = 'mob'"
  default     = "mob"
}

variable "environment" {
  description = "Name of the environment the resource is deployed to, e.g. Dev, Test, Int, etc."
  default     = ""
}

variable "region_name" {
  type        = string
  description = "Name of the region e.g. eu-west-2"
  default     = "eu-west-2"
}

variable "environment_azs" {
  type        = map(string)
  description = "Map list of the number of Availability Zones to use and which character to use for the suffix e.g eu-west-2c"
  default = {
    "0" = "a"
    "1" = "b"
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}


# -------------------------------------------------------------------------------------------------------------------
# Locally defined variables
# -------------------------------------------------------------------------------------------------------------------

locals {

  # -------------------------------------------------------------------------------------------------------------------
  # Standard Tags for AWS Resources - see https://www.terraform.io/docs/configuration/locals.html
  # -------------------------------------------------------------------------------------------------------------------
  default_tags = {
    Environment = "${var.environment}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
  }

  # -------------------------------------------------------------------------------------------------------------------
  # Standard List Tags for AWS Resources - used for Autoscaling groups
  # -------------------------------------------------------------------------------------------------------------------
  default_list_tags = [
    { key = "Environment", value = "${var.environment}", propagate_at_launch = true },
    { key = "Owner", value = "${var.owner}", propagate_at_launch = true },
    { key = "Project", value = "${var.project}", propagate_at_launch = true },
  ]

  # -------------------------------------------------------------------------------------------------------------------
  # Name prefix for all named resources which follows the mobilise Cloud Handbook:
  # example: mob-mgmt-jenkins-rtbl
  # -------------------------------------------------------------------------------------------------------------------

  name_prefix = "${var.client_abbr}-${var.environment}"
}
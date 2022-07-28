variable "account_no" {
  type        = string
  description = "AWS Account No"
}

variable "owner" {
  type        = string
  description = "The Owner of the environment e.g Mobilise"
  default     = "Mobilise-Academy"
}

variable "project" {
  type        = string
  description = "Name of the project being deployed"
  default     = "Workshop"
}

variable "client_abbr" {
  type        = string
  description = "Abbreviated name of the client e.g Mobilise = 'mob'"
  default     = "Mob"
}

variable "region_name" {
  type        = string
  description = "Name of the region e.g. eu-west-2"
  default     = "eu-west-2"
}

variable "environment" {
  description = "Name of the environment the resource is deployed to, e.g. Dev, Test, Int, etc."
  default     = ""
}

/* variable "environment_domain" {
  type        = string
  description = "Name of the environment top level domain."
} */

variable "environment_azs" {
  type        = map(string)
  description = "Map list of the number of Availability Zones to use and which character to use for the suffix e.g eu-west-2c"
  default = {
    "0" = "a"
    "1" = "b"
    "2" = "c"
  }
}

# -------------------------------------------------------------------------------------------------------------------
# Meta data used for AWS tags
# -------------------------------------------------------------------------------------------------------------------

variable "meta_build_no" { type = string }
variable "meta_repo_name" { type = string }
variable "meta_repo_branch" { type = string }
variable "meta_deployed_by" { type = string }
variable "meta_last_commit_author" { type = string }

# -------------------------------------------------------------------------------------------------------------------
# Locally defined variables
# -------------------------------------------------------------------------------------------------------------------

locals {

  # -------------------------------------------------------------------------------------------------------------------
  # Standard Tags for AWS Resources - see https://www.terraform.io/docs/configuration/locals.html
  # -------------------------------------------------------------------------------------------------------------------

  default_tags = {
    DeployedBy  = "${var.meta_deployed_by}"
    Environment = "${var.environment}"
    Owner       = "${var.owner}"
    Project     = "${var.project}"
  }

  # -------------------------------------------------------------------------------------------------------------------
  # Standard List Tags for AWS Resources - used for Autoscaling Groups
  # -------------------------------------------------------------------------------------------------------------------

  default_list_tags = [
    { key = "Branch", value = "${var.meta_repo_branch}", propagate_at_launch = true },
    { key = "BuildNo", value = "${var.meta_build_no}", propagate_at_launch = true },
    { key = "DeployedBy", value = "${var.meta_deployed_by}", propagate_at_launch = true },
    { key = "Environment", value = "${var.environment}", propagate_at_launch = true },
    { key = "Owner", value = "${var.owner}", propagate_at_launch = true },
    { key = "Project", value = "${var.project}", propagate_at_launch = true },
    { key = "LastAppliedUTC", value = "${timestamp()}", propagate_at_launch = true },
    { key = "LastCommitAuthor", value = "${var.meta_last_commit_author}", propagate_at_launch = true },
    { key = "Repository", value = "${var.meta_repo_name}", propagate_at_launch = true }
  ]

  # -------------------------------------------------------------------------------------------------------------------
  # Name prefix for all named resources which follows the Mobilise Cloud Handbook:
  # example: mob-mgmt-jenkins-rtbl
  # -------------------------------------------------------------------------------------------------------------------

  name_prefix = "${var.client_abbr}-${var.environment}"
}

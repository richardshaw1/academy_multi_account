# ===================================================================================================================
# Database
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_db" {
  description = "true or false whether a database should be created"
  default     = false
}

variable "subnet_ids" {
  description = "A list of subnet ids as defined in subnet.tfvars to attach to databases"
  default     = []
}

variable "db_cluster" {
  description = "map of all db clusters"
  default     = []
}

variable "db_cluster_instance" {
  description = "map of db cluster instances"
  default     = []
}

variable "db_subnet_group" {
  description = "map of db subnet groups"
  default     = []
}


# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# -------------------------------------------------------------------------------------------------------------------
# RDS Aurora Cluster
# -------------------------------------------------------------------------------------------------------------------
resource "aws_rds_cluster" "rds_cluster" {
  for_each = { for key, value in var.db_cluster :
    key => value
  if lookup(value, "create_db", false) == true }
  cluster_identifier        = lookup(each.value, "cluster_identifier", "")
  engine                    = lookup(each.value, "engine", "")
  engine_version            = lookup(each.value, "engine_version", "")
  availability_zones        = lookup(each.value, "availability_zones", "")
  database_name             = lookup(each.value, "database_name", "")
  master_username           = lookup(each.value, "master_username", "")
  master_password           = lookup(each.value, "master_password", "")
  backup_retention_period   = lookup(each.value, "backup_retention_period", "")
  preferred_backup_window   = lookup(each.value, "preferred_backup_window", "")
  db_subnet_group_name      = lookup(each.value, "db_subnet_group_name", "")
  db_cluster_instance_class = lookup(each.value, "db_cluster_instance_class", "")
  kms_key_id                = lookup(each.value, "kms_key_id", "")
  storage_encrypted         = lookup(each.value, "storage_encrypted", "")
}

resource "aws_rds_cluster_instance" "db_cluster_instance" {
  for_each = { for key, value in var.db_cluster_instance :
  key => value }
  cluster_identifier = lookup(each.value, "cluster_identifier", "")
  instance_class     = lookup(each.value, "instance_class", "")
  engine             = lookup(each.value, "engine", "")
  engine_version     = lookup(each.value, "engine_version", "")
}

# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "db_subnet_group" {
  for_each = { for key, value in var.db_subnet_group :
  key => value }
  name       = lookup(each.value, "name", "")
  subnet_ids = lookup(each.value, "subnet_ids")
  tags       = {}
}
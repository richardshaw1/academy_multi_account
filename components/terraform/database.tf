# ===================================================================================================================
# Database
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_db" {
  description = "true or false whether a database should be created"
  default = false
}

variable "db_subnet_ids" {
  description = "A list of subnet ids as defined in subnet.tfvars to attach to databases"
  default     = []
}

variable "db_cluster" {
 description = "map of all db clusters"
 default = []
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# -------------------------------------------------------------------------------------------------------------------
# RDS Aurora Cluster
# -------------------------------------------------------------------------------------------------------------------
resource "aws_rds_cluster" "default" {
  for_each = { for key, value in var.db_cluster :
    key => value
  if lookup(value, "create_instance", false) == true }
  cluster_identifier      = lookup(each.value, "cluster_identifier", "")
  engine                  = lookup(each.value, "engine", "")
  engine_version          = lookup(each.value, "engine_version", "")
  availability_zones      = lookup(each.value, "availability_zones", "")
  database_name           = lookup(each.value, "database_name", "")
  master_username         = lookup(each.value, "master_username", "")
  master_password         = lookup(each.value, "master_password", "")
  backup_retention_period = lookup(each.value, "backup_retention_period", "")
  preferred_backup_window = lookup(each.value, "preferred_backup_window", "")
}

# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = [for sn in var.db_subnet_ids : aws_subnet.env_subnet[sn].id]

  tags = {
    Name = ""
  }
}
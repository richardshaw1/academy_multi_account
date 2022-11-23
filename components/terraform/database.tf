# ===================================================================================================================
# Aurora RDS Database
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================

variable "db_cluster" {
  type        = map(any)
  description = "map of all db clusters"
  default     = {}
}

variable "db_cluster_instances" {
  type        = map(any)
  description = "map of db cluster instances"
  default     = {}
}

variable "db_subnet_group" {
  type        = map(any)
  description = "map of db subnet groups"
  default     = {}
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
  cluster_identifier              = lookup(each.value, "cluster_identifier", "")
  engine                          = lookup(each.value, "engine", "")
  engine_version                  = lookup(each.value, "engine_version", "")
  availability_zones              = lookup(each.value, "availability_zones", "")
  database_name                   = lookup(each.value, "database_name", "")
  master_username                 = lookup(each.value, "master_username", "")
  master_password                 = lookup(each.value, "master_password", "")
  db_cluster_parameter_group_name = lookup(each.value, "cluster_parameter_group_name", "")
  backup_retention_period         = lookup(each.value, "backup_retention_period", "")
  iam_roles                       = lookup(each.value, "iam_roles", "")
  preferred_backup_window         = lookup(each.value, "preferred_backup_window", "")
  db_subnet_group_name            = lookup(each.value, "db_subnet_group_name", "")
  kms_key_id                      = lookup(each.value, "kms_key_id", "")
  storage_encrypted               = lookup(each.value, "storage_encrypted", "")
  vpc_security_group_ids          = [for sg in lookup(each.value, "security_group_ids", "") : aws_security_group.ec2_sg[sg].id]
  skip_final_snapshot             = lookup(each.value, "skip_final_snapshot", "")
  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "cluster_identifier", "")
    },
  )
  lifecycle {
    ignore_changes = [availability_zones]
  }
  depends_on = [aws_db_subnet_group.db_subnet_group]
}
# -------------------------------------------------------------------------------------------------------------------
# RDS Aurora Cluster Instances
# -------------------------------------------------------------------------------------------------------------------
resource "aws_rds_cluster_instance" "db_cluster_instance" {
  for_each = { for key, value in var.db_cluster_instances :
    key => value
  if lookup(value, "create_aurora_instance", false) == true }
  identifier              = lookup(each.value, "identifier", "")
  cluster_identifier      = aws_rds_cluster.rds_cluster[lookup(each.value, "cluster_id", "")].id
  instance_class          = lookup(each.value, "instance_class", "")
  engine                  = lookup(each.value, "engine", "")
  engine_version          = lookup(each.value, "engine_version", "")
  db_parameter_group_name = lookup(each.value, "db_parameter_group_name", "")
  promotion_tier          = lookup(each.value, "promotion_tier", "")
  availability_zone       = lookup(each.value, "availability_zone", "")
  tags = merge(
    local.default_tags,
    {
      "Name" = "${lookup(each.value, "identifier", "")}"
    },
  )
  depends_on = [aws_rds_cluster.rds_cluster]
}

# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "db_subnet_group" {
  for_each    = var.db_subnet_group
  name        = lookup(each.value, "name", "")
  description = lookup(each.value, "description", "")
  subnet_ids  = [for sn in lookup(each.value, "subnets", "") : aws_subnet.env_subnet[sn].id]
  tags = merge(
    local.default_tags,
    {
      "Name" = lookup(each.value, "name", "")
    },
  )
  depends_on = [aws_subnet.env_subnet]
}
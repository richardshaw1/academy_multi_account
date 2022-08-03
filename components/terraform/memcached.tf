# ===================================================================================================================
# Elasticache for Memcached Cluster
# ===================================================================================================================
# ===================================================================================================================
# VARIABLES
# ===================================================================================================================
variable "create_elasticache_cluster" {
    default = false
}

variable "elasticache_clusters" {
  description = "map of all db clusters"
  default     = []
}

variable "elasticache_subnet_groups" {
  description = "map of all db clusters"
  default     = []
}


# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create Memcached Cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_elasticache_cluster" "elasticache_cluster" {
      for_each = { for key, value in var.elasticache_clusters :
    key => value
  if lookup(value, "create_elasticache_cluster", false) == true }
  cluster_id           = lookup(each.value, "cluster_id", "")
  engine               = lookup(each.value, "engine", "")
  node_type            = lookup(each.value, "node_type", "")
  num_cache_nodes      = lookup(each.value, "num_cache_nodes", "")
  parameter_group_name = lookup(each.value, "parameter_group_name", "")
  port                 = lookup(each.value, "port", "")
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  for_each = { for key, value in var.elasticache_subnet_groups :
  key => value }
  name       = lookup(each.value, "name", "")
  subnet_ids = lookup(each.value, "subnet_ids", "")
}
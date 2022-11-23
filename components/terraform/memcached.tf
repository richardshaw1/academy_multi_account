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
  type        = map(any)
  description = "map of all db clusters"
  default     = {}
}

variable "elasticache_subnet_groups" {
  type        = map(any)
  description = "map of all db clusters"
  default     = {}
}


# ===================================================================================================================
# RESOURCE CREATION
# ===================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Create Memcached Cluster
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_elasticache_cluster" "elasticache_cluster" {
  for_each                     = var.elasticache_clusters
  cluster_id                   = lookup(each.value, "cluster_id", "")
  engine                       = lookup(each.value, "engine", "")
  engine_version               = lookup(each.value, "engine_version", "")
  node_type                    = lookup(each.value, "node_type", "")
  num_cache_nodes              = lookup(each.value, "num_cache_nodes", "")
  parameter_group_name         = lookup(each.value, "parameter_group_name", "")
  port                         = lookup(each.value, "port", "")
  preferred_availability_zones = lookup(each.value, "preferred_availability_zones", "")
  security_group_ids           = [for sg in lookup(each.value, "security_group_ids", "") : aws_security_group.ec2_sg[sg].id]
  subnet_group_name            = lookup(each.value, "subnet_group_name", "")

  tags = merge(
    local.default_tags,
    { "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = lookup(each.value, "tag_project", "")
    },
  )
  depends_on = [aws_elasticache_subnet_group.elasticache_subnet_group]
}

resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  for_each   = var.elasticache_subnet_groups
  name       = lookup(each.value, "subnet_group_name", "")
  subnet_ids = [for sn in lookup(each.value, "subnet_ids", "") : aws_subnet.env_subnet[sn].id]


  tags = merge(
    local.default_tags,
    {

      "Name"    = "${local.name_prefix}-${lookup(each.value, "tag_name", "")}"
      "Owner"   = lookup(each.value, "tag_owner", "")
      "Project" = lookup(each.value, "tag_project", "")
    },
  )
}
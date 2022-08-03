# -------------------------------------------------------------------------------------------------------------------
# Elasticache Memcached Cluster Variables
# -------------------------------------------------------------------------------------------------------------------

create_elasticache_cluster = true

elasticache_clusters  = {
    "memcached_cluster" = {
  cluster_id           = "memcached-cluster"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
}
}

elasticache_subnet_groups = {
    "memcached_subnet_group" = {
  name       = "memcached-subnet-group"
  subnet_ids = ["2", "3"]
}
}
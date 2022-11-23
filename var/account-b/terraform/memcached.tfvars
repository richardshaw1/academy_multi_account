# -------------------------------------------------------------------------------------------------------------------
# Elasticache Memcached Cluster Variables
# -------------------------------------------------------------------------------------------------------------------

create_elasticache_cluster = true

elasticache_clusters = {
  "memcached_cluster" = {
    cluster_id                   = "memcached-cluster-01"
    engine                       = "memcached"
    engine_version               = "1.6.12"
    node_type                    = "cache.t2.micro"
    num_cache_nodes              = "2"
    parameter_group_name         = "default.memcached1.6"
    port                         = "11211"
    preferred_availability_zones = ["eu-west-2a", "eu-west-2b"]
    security_group_ids           = ["memcached_sg"]
    subnet_group_name            = "memcached-subnet-group-01"
    tag_name                     = "memcached-cluster"
    tag_owner                    = "mobilise-academy"
    tag_project                  = "mobilise-academy-workshop"
  }
}

elasticache_subnet_groups = {
  "memcached_subnet_group" = {
    subnet_group_name = "memcached-subnet-group-01"
    subnet_ids        = ["2", "3"]
    tag_name          = "memcached-cluster"
    tag_owner         = "mobilise-academy"
    tag_project       = "mobilise-academy-workshop"
  }
}
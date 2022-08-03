create_db = true

# -------------------------------------------------------------------------------------------------------------------
# Aurora Database Cluster for Wordpress DB
# -------------------------------------------------------------------------------------------------------------------

db_cluster = {
  "aurora_db_cluster" = {
  cluster_identifier        = "aurora-cluster"
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.10.2"
  availability_zones        = ["eu-west-2a", "eu-west-2b"]
  database_name             = "wordpress_db"
  master_username           = "academy_admin"
  master_password           = "Mobilise_Academy123"
  backup_retention_period   = 1
  preferred_backup_window   = ""
  db_subnet_group_name      = "aurora_subnet_group"
  db_cluster_instance_class = "db.t3.small"
  kms_key_id                = ""
  storage_encrypted         = "true"
  }
}

db_cluster_instance = {
  "aurora_cluster_instance_1" = {
  cluster_identifier = "aurora-cluster.id"
  instance_class     = "db.t3.small"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.10.2"
}
}

# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------

db_subnet_group = {
  "aurora_subnet_group" = {
name        = "aurora-subnet-group"
subnet_ids  = ["2", "3"]
}
}
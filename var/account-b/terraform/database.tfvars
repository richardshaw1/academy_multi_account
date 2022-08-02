create_db = true

db_cluster = {
  "aurora_db_cluster" = {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.10.2"
  availability_zones      = ["eu-west-2a", "eu-west-2b"]
  database_name           = "wordpress_db"
  master_username         = "academy_admin"
  master_password         = "Mobilise_Academy123"
  backup_retention_period = 1
  preferred_backup_window = ""
  }
}
# -------------------------------------------------------------------------------------------------------------------
# Database Subnet IDs
# -------------------------------------------------------------------------------------------------------------------

db_subnet_ids = ["2", "3"]
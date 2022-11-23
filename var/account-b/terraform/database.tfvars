/* create_db = true */

# -------------------------------------------------------------------------------------------------------------------
# Aurora Database Cluster for Wordpress DB
# -------------------------------------------------------------------------------------------------------------------

db_cluster = {
  "aurora_db_cluster" = {
    create_db                    = true
    cluster_identifier           = "aurora-cluster"
    engine                       = "aurora-mysql"
    engine_version               = "5.7.mysql_aurora.2.10.2"
    availability_zones           = ["eu-west-2a", "eu-west-2b"]
    database_name                = "wordpress_db"
    master_username              = "academy_admin"
    master_password              = "Mobilise_Academy123"
    cluster_parameter_group_name = "default.aurora-mysql5.7"
    backup_retention_period      = "1"
    iam_roles                    = ["arn:aws:iam::226283484947:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]
    preferred_backup_window      = ""
    db_subnet_group_name         = "aurora-subnet-group-01"
    kms_key_id                   = ""
    storage_encrypted            = "true"
    security_group_ids           = ["aurora_sg"]
    skip_final_snapshot          = true
  }
}

db_cluster_instances = {
  "aurora_cluster_instance_1" = {
    create_aurora_instance  = true
    identifier              = "aurora-cluster-instance-01"
    cluster_id              = "aurora_db_cluster"
    instance_class          = "db.t3.small"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.2"
    db_parameter_group_name = "default.aurora-mysql5.7"
    promotion_tier          = "1"
    availability_zone       = "eu-west-2a"
  }
  "aurora_cluster_instance_2" = {
    create_aurora_instance  = true
    identifier              = "aurora-cluster-instance-02"
    cluster_id              = "aurora_db_cluster"
    instance_class          = "db.t3.small"
    engine                  = "aurora-mysql"
    engine_version          = "5.7.mysql_aurora.2.10.2"
    db_parameter_group_name = "default.aurora-mysql5.7"
    promotion_tier          = "0"
    availability_zone       = "eu-west-2b"
  }
}

# -------------------------------------------------------------------------------------------------------------------
# Database Subnet Groups
# -------------------------------------------------------------------------------------------------------------------

db_subnet_group = {
  "aurora_subnet_group" = {
    name        = "aurora-subnet-group-01"
    description = "subnet group for the aurora rds database cluster"
    subnets     = ["2", "3"]
  }
}
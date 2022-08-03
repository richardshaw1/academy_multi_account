# -------------------------------------------------------------------------------------------------------------------
# EFS Variables
# -------------------------------------------------------------------------------------------------------------------

create_efs = true

efs  = {
    "efs" = {
  creation_token       = ""
  tag_name             = "memcached-cluster"
  tag_owner            = "mobilise-academy"
  tag_project          = "mobilise-academy-workshop"
}
}

efs_backup_policy = {
    "efs_backup_policy" = {
  backup_policy = {
    status = "ENABLED"
  }
}
}
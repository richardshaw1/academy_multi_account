# -------------------------------------------------------------------------------------------------------------------
# EFS Variables
# -------------------------------------------------------------------------------------------------------------------

create_efs = true

ef_stores = {
  "efs_01" = {
    "encrypted"        = true
    "kms_key_id"       = "arn:aws:kms:eu-west-2:226283484947:key/2b162fa5-a6b6-4903-9840-be3cb80ef1b7"
    "performance_mode" = "generalPurpose"
    "throughput_mode"  = "bursting"
  }
}

efs_mount_targets = {
  "efs_mount_targets" = {
    "ef_store"       = "efs_01"
    "security_group" = "efs_sg"
    "subnet"         = "2"
  }
}
efs_backup_policy = {
  "backup" = {
    "ef_store_name" = "efs_01"
    "status"        = "ENABLED"
  }
}
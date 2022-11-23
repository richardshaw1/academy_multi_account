# ----------------------------------------------------------------------------------------------------------------------
# Network Load Balancera Variables
# ----------------------------------------------------------------------------------------------------------------------

nlbs = {
  #  Squid NLB load balancer 01 -----------------------------------------------------------------------------------
  "squid_nlb" = {
<<<<<<< HEAD
    "create_nlb"         = true
    "nlb_name"           = "squid-nlb"
    "nlb_internal"       = false
    "nlb_czlb"           = true
    "nlb_subnets"        = ["0", "1"]
    "tag_owner"          = "Mobilise-Academy"
    "tag_project"        = "Workshop"
=======
    "create_nlb"   = true
    "nlb_name"     = "squid-nlb"
    "nlb_internal" = false
    "nlb_czlb"     = true
    "nlb_subnets"  = ["0", "1"]
    "tag_owner"    = "Mobilise-Academy"
    "tag_project"  = "Workshop"
>>>>>>> origin/main
  }
}

nlb_listeners = {
  # Squid NLB listener 01 ----------------------------------------------------------------------------------------
  "squid_nlb_80_f" = {
    "create_nlb"            = true
    "nlb_resource"          = "squid_nlb"
    "port"                  = 80
    "protocol"              = "TCP"
    "target_group_resource" = "squid_nlb_tg_01"
  }
}

nlb_target_groups = {
  # Squid NLB target groups 01 -----------------------------------------------------------------------------------
  "squid_nlb_tg_01" = {
<<<<<<< HEAD
    "create_nlb_tg"     = true
=======
    "create_nlb_tg"  = true
>>>>>>> origin/main
    "tg_name"        = "squid-tg-1"
    "tg_port"        = 80
    "tg_protocol"    = "TCP"
    "tg_target_type" = "instance"
    "hc_protocol"    = "TCP"
  }
}

nlb_targets = {
  # Squid NLB targets 01 -----------------------------------------------------------------------------------------
  "squid_target_1" = {
    "create_nlb_target"     = true
    "target_group_resource" = "squid_nlb_tg_01"
    "target_id"             = "squid_proxy_01"
  }
  # Squid NLB targets 02 -----------------------------------------------------------------------------------------
  "squid_target_2" = {
    "create_nlb_target"     = true
    "target_group_resource" = "squid_nlb_tg_01"
    "target_id"             = "squid_proxy_02"
  }
}
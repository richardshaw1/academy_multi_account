# ----------------------------------------------------------------------------------------------------------------------
# Network Load Balancer Specific Variables
# ----------------------------------------------------------------------------------------------------------------------
create_nlb = true

nlbs = {
  #  Squid NLB load balancer 01 -----------------------------------------------------------------------------------
  "squid_nlb" = {
    "nlb_name"           = "squid-nlb"
    "nlb_internal"       = false
    "nlb_subnets"        = ["0", "1"]
    "tag_owner"          = "Neil Thomas"
    "tag_project"        = "FOSS"
    "tag_system"         = "SAP"
  }
}

nlb_listeners = {
  # Squid NLB listener 01 ----------------------------------------------------------------------------------------
  "squid_nlb_80_f" = {
    "nlb_resource"          = "squid_nlb"
    "port"                  = 80
    "protocol"              = "TCP"
    "target_group_resource" = "squid_nlb_tg_01"
  }
}

nlb_target_groups = {
  # Squid NLB target groups 01 -----------------------------------------------------------------------------------
  "squid_nlb_tg_01" = {
    "tg_name"        = "squid-tg-1"
    "tg_port"        = 80
    "tg_protocol"    = "TCP"
    "tg_target_type" = "instance"
    "hc_protocol"    = "TCP"
  }
}

nlb_targets = {
  # Squid NLB targets 01 -----------------------------------------------------------------------------------------
  "squid_target_1_10.0.0.10_80" = {
    "target_group_resource" = "squid_nlb_tg_01"
    "target_ip"             = "10.0.0.10"
    "target_port"           = 80
    "target_az"             = "eu-west-2a"
  }
    # Squid NLB targets 02 -----------------------------------------------------------------------------------------
  "squid_target_1_10.0.0.40_80" = {
    "target_group_resource" = "squid_nlb_tg_01"
    "target_ip"             = "10.0.0.40"
    "target_port"           = 80
    "target_az"             = "eu-west-2b"
  }
}
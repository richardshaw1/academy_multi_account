# ######################################################################################################################
# Application Load Balancer Specific Variables
# ######################################################################################################################
# ======================================================================================================================
# Load Balancers
# ======================================================================================================================
albs = {
  # Wordpress Application Load Balancer ------------------------------------------------------------------------------
  "wordpress_alb" = {
    "alb_name"     = "wordpress-alb"
    "alb_internal" = true
    "alb_subnets"  = ["0", "1"]
    "alb_sgs"      = ["wordpress_alb_sg"]
    "tag_owner"    = "Mobilise-Academy"
    "tag_project"  = "Workshop"
  }
}

alb_listeners_f = {
  # WordPress ALB Listener ----------------------------------------------------------------------------------
  "wordpress_alb_80_f" = {
    "alb"          = "wordpress_alb"
    "port"         = 80
    "protocol"     = "HTTP"
    "target_group" = "wordpress_alb_tg"
    "acm_cert"     = ""
    "ssl_policy"   = ""
  }
}

alb_tgs = {
  # WordPress target group -----------------------------------------------------------------------------
  "wordpress_alb_tg" = {
    "tg_name"       = "wp-alb-tg"
    "tg_port"       = 80
    "tg_protocol"   = "HTTP"
    "tg_type"       = "instance"
    "hc_interval"   = 30
    "hc_protocol"   = "HTTP"
    "hc_path"       = "/"
    "success_codes" = "200,302"
  }
}

alb_targets = {
  # WordPress ALB targets -----------------------------------------------------------------------------------------
  "wordpress_tg_10.1.0.13_80" = {
    "target_ip"         = "10.1.0.13"
    "target_group"      = "wordpress_alb_tg"
    "target_port"       = 80
    "availability_zone" = "eu-west-2a"
  }
    "wordpress_tg_10.1.0.43_80" = {
    "target_ip"         = "10.1.0.43"
    "target_group"      = "wordpress_alb_tg"
    "target_port"       = 80
    "availability_zone" = "eu-west-2b"
  }
}
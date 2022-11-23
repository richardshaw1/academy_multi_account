# ######################################################################################################################
# Application Load Balancer Specific Variables
# ######################################################################################################################
# ======================================================================================================================
# Load Balancers
# ======================================================================================================================
albs = {
  # Wordpress Application Load Balancer ------------------------------------------------------------------------------
  "wordpress_alb" = {

    alb_name     = "wordpress-alb"
    alb_internal = true
    alb_type     = "application"
    alb_subnets  = ["0", "1"]
    alb_sgs      = ["wordpress_alb_sg"]
    tag_owner    = "Mobilise-Academy"
    tag_project  = "Workshop"
  }
}

alb_listeners_f = {
  # WordPress ALB Listener ----------------------------------------------------------------------------------
  "wordpress_alb_80_f" = {
    alb_resource_name              = "wordpress_alb"
    alb                            = "wordpress_alb"
    port                           = 80
    protocol                       = "HTTP"
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_action                     = "forward"
  }
}

alb_target_groups = {
  # WordPress target group -----------------------------------------------------------------------------
  "wordpress_alb_tg" = {
    tg_name             = "wp-alb-tg"
    tg_port             = "80"
    tg_protocol         = "HTTP"
    tg_type             = "instance"
    hc_port             = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    hc_timeout          = 10
    hc_interval         = 30
    hc_protocol         = "HTTP"
    hc_path             = "/"
    success_codes       = "200,302"
  }
}

alb_targets = {
  # WordPress ALB targets -----------------------------------------------------------------------------------------
  "wordpress_tg_01" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress_01"
  }

  "wordpress_tg_02" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress_02"
  }

    "wordpress_tg_test" = {
    add_alb_targets                = false
    alb_target_group_resource_name = "wordpress_alb_tg"
    alb_target_resource_name       = "wordpress_test"
  }
}
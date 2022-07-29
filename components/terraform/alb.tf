# ======================================================================================================================
# Application Load balancers - The security groups and rules are defined in sgs.tfvars
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "albs" {
  description = "A map of all application load balancers to create"
  default     = {}
}
variable "alb_tgs" {
  description = "A map of all the target groups"
  default     = {}
}

variable "alb_targets" {
  description = "A map of all targets to assign to a target group"
  default     = {}
}

variable "alb_listeners_f" {
  description = "A map of all listeners that have a default action of forward"
  default     = {}
}

variable "alb_listener_rules_f" {
  description = "A map of all listener rules that have a default action of forward"
  default     = {}
}

variable "alb_listeners_r" {
  description = "A map of all listeners that have a default action of redirect"
  default     = {}
}

variable "alb_listener_rules_r" {
  description = "A map of all listener rules that have a default action of redirect"
  default     = {}
}

variable "alb_listeners_fr" {
  description = "A map of all listeners that have default action of fixed-response"
  default     = {}
}

variable "alb_listener_rules_fr" {
  description = "A map of all listener rules that have default action of fixed-response"
  default     = {}
}

# ======================================================================================================================
# RESOURCES
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Application load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "env_alb" {
  name               = "${var.client_abbr}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for sn in lookup(each.value, "alb_subnets", []) : aws_subnet.env_subnet[sn].id]
  security_groups    = [aws_security_group.ec2_sg[element(lookup(each.value, "alb_sgs", ""), 0)].id]
  
  tags = merge(
    local.default_tags,
    {
      "Name"           = "${local.name_prefix}-${lookup(each.value, "alb_name", "")}"
      "Owner"          = "Mobilise-Academy"
      "Project"        = "Workshop"
    }
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Listeners
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "alb_listener_r" {
  load_balancer_arn = aws_lb.env_alb.arn
  port              = lookup(each.value, "port", 0)
  protocol          = lookup(each.value, "protocol", "")

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.env_alb_tg.arn
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Target Groups
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "env_alb_tg" {
  for_each    = var.alb_tgs
  name        = "${local.name_prefix}-${lookup(each.value, "tg_name", "")}"
  target_type = lookup(each.value, "tg_type", "")
  port        = lookup(each.value, "tg_port", "")
  protocol    = lookup(each.value, "tg_protocol", "")
  vpc_id      = aws_vpc.env_vpc[0].id
  stickiness {
    type            = "lb_cookie"
    enabled         = lookup(each.value, "stickiness", false)
    cookie_duration = lookup(each.value, "cookie_duration", 86400)
  }
  health_check {
    interval = lookup(each.value, "hc_interval", 0)
    protocol = lookup(each.value, "hc_protocol", "HTTP")
    port     = lookup(each.value, "hc_port", "traffic-port")
    path     = lookup(each.value, "hc_path", "")
    matcher  = lookup(each.value, "success_codes", "200")
  }
}
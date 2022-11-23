# ======================================================================================================================
# Application Load balancers - The security groups and rules are defined in sgs.tfvars
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "albs" {
  type        = map(any)
  description = "A map of all application load balancers to create"
  default     = {}
}
variable "alb_target_groups" {
  type        = map(any)
  description = "A map of all the target groups"
  default     = {}
}

variable "alb_targets" {
  type        = map(any)
  description = "A map of all targets to assign to a target group"
  default     = {}
}

variable "alb_listeners_f" {
  type        = map(any)
  description = "A map of all listeners that have a default action of forward"
  default     = {}
}

# ======================================================================================================================
# RESOURCES
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Application load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "env_alb" {
  for_each           = var.albs
  name               = "${var.client_abbr}-${var.environment}-alb"
  internal           = lookup(each.value, "alb_internal", "")
  load_balancer_type = lookup(each.value, "alb_type", "")
  subnets            = [for sn in lookup(each.value, "alb_subnets", []) : aws_subnet.env_subnet[sn].id]
  security_groups    = [aws_security_group.ec2_sg[element(lookup(each.value, "alb_sgs", ""), 0)].id]

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "alb_name", "")}"
    }
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Listeners
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "alb_listener_f" {
  for_each          = var.alb_listeners_f
  load_balancer_arn = aws_lb.env_alb[lookup(each.value, "alb", "")].arn
  port              = lookup(each.value, "port", "")
  protocol          = lookup(each.value, "protocol", "")

  default_action {
    type             = lookup(each.value, "alb_action", "")
    target_group_arn = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn
  }
  depends_on = [aws_lb_target_group.env_alb_tg]
}

# ----------------------------------------------------------------------------------------------------------------------
# Target Groups
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "env_alb_tg" {
  for_each    = var.alb_target_groups
  name        = "${local.name_prefix}-${lookup(each.value, "tg_name", "")}"
  port        = lookup(each.value, "tg_port", "")
  protocol    = lookup(each.value, "tg_protocol", "")
  target_type = lookup(each.value, "tg_type", "")
  vpc_id = aws_vpc.env_vpc[0].id
  stickiness {
    type            = "lb_cookie"
    enabled         = lookup(each.value, "stickiness", false)
    cookie_duration = lookup(each.value, "cookie_duration", 86400)
  }
  health_check {
    healthy_threshold   = lookup(each.value, "healthy_threshold", "")
    unhealthy_threshold = lookup(each.value, "unhealthy_threshold", "")
    timeout             = lookup(each.value, "hc_timeout", "")
    interval            = lookup(each.value, "hc_interval", "")
    protocol            = lookup(each.value, "hc_protocol", "")
    port                = lookup(each.value, "hc_port", "")
    path                = lookup(each.value, "hc_path", "")
    matcher             = lookup(each.value, "success_codes", "")

  }
  depends_on = [aws_lb.env_alb]
}

# ----------------------------------------------------------------------------------------------------------------------
# Application Load Balancer Targets
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "env_alb_target_group_attach" {
  for_each = { for key, value in var.alb_targets :
    key => value
  if lookup(value, "add_alb_targets", false) == true }
  target_group_arn = aws_lb_target_group.env_alb_tg[lookup(each.value, "alb_target_group_resource_name", "")].arn
  target_id        = aws_instance.instance_standard[lookup(each.value, "alb_target_resource_name", "")].id

  depends_on = [aws_instance.instance_standard]
}
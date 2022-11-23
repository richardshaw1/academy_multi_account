# ======================================================================================================================
# Network Load Balancer
# ======================================================================================================================
# ======================================================================================================================
# VARIABLES
# ======================================================================================================================
variable "create_nlb" {
  description = "Creates Network Load Balancer"
  default     = false
}

variable "create_nlb_tg" {
  description = "Creates Network Load Balancer target group"
  default     = false
}

variable "nlbs" {
  description = "A map of network load balancers"
  default     = {}
}

# Forwarding listener
variable "nlb_listeners" {
  description = "A map of network load balancer listeners"
  default     = {}
}

variable "nlb_listener_rules_f" {
  description = "A map of all listener rules that have a default action of forward"
  default     = {}
}

variable "nlb_target_groups" {
  type        = map(any)
  description = "A map of network load balancer target groups"
  default     = {}
}

variable "nlb_targets" {
  description = "A map of target instances linked to the nlb target group that targets them"
  default     = {}
}

# ======================================================================================================================
# RESOURCE CREATION
# ======================================================================================================================
# ----------------------------------------------------------------------------------------------------------------------
# Network load balancer
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "env_lb_nlb" {
  for_each = { for key, value in var.nlbs :
    key => value
  if lookup(value, "create_nlb", false) == true }
  name                             = "${local.name_prefix}-${lookup(each.value, "nlb_name", "")}"
  internal                         = lookup(each.value, "nlb_internal", "")
  enable_cross_zone_load_balancing = lookup(each.value, "nlb_czlb", "")
  load_balancer_type               = "network"
  subnets                          = [for sn in lookup(each.value, "nlb_subnets", []) : aws_subnet.env_subnet[sn].id]

  tags = merge(
    local.default_tags,
    {
      "Name"    = "${local.name_prefix}-${lookup(each.value, "nlb_name")}"
      "Owner"   = "Mobilise-Academy"
      "Project" = "Workshop"
      "VPC"     = aws_vpc.env_vpc[0].id
    },
  )
}

# ----------------------------------------------------------------------------------------------------------------------
# Network load balancer Listener + Rule - Forward
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_listener" "env_lb_nlb_listener" {
  for_each = { for key, value in var.nlb_listeners :
    key => value
  if lookup(value, "create_nlb", false) == true }
  load_balancer_arn = aws_lb.env_lb_nlb[lookup(each.value, "nlb_resource", 0)].arn
  port              = lookup(each.value, "port", 0)
  protocol          = lookup(each.value, "protocol", "")

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.env_lb_nlb_tg[lookup(each.value, "target_group_resource", "")].arn
  }
  depends_on = [aws_lb.env_lb_nlb]
}

# ----------------------------------------------------------------------------------------------------------------------
# Network Load Balancer Target Groups
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group" "env_lb_nlb_tg" {
  for_each = { for key, value in var.nlb_target_groups :
    key => value
  if lookup(value, "create_nlb_tg", false) == true }
  name        = "${local.name_prefix}-${lookup(each.value, "tg_name", true)}"
  port        = lookup(each.value, "tg_port", "")
  protocol    = lookup(each.value, "tg_protocol", "")
  target_type = lookup(each.value, "tg_target_type", "")
  vpc_id      = aws_vpc.env_vpc[0].id
  health_check {
    protocol            = lookup(each.value, "hc_protocol", "HTTP")
    port                = lookup(each.value, "hc_port", "traffic-port")
    path                = lookup(each.value, "hc_path", "")
    healthy_threshold   = lookup(each.value, "hc_healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value, "hc_unhealthy_threshold", 3)
    timeout             = lookup(each.value, "hc_timeout", null)
    interval            = lookup(each.value, "hc_interval", 10)
  }
  depends_on = [aws_lb.env_lb_nlb]
}
# ----------------------------------------------------------------------------------------------------------------------
# Network load balancer targets
# ----------------------------------------------------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "env_lb_targets" {
  for_each = { for key, value in var.nlb_targets :
    key => value
  if lookup(value, "create_nlb_target", false) == true }
  target_group_arn = aws_lb_target_group.env_lb_nlb_tg[lookup(each.value, "target_group_resource", "")].arn
  target_id        = aws_instance.instance_standard[lookup(each.value, "target_id", "")].id
}
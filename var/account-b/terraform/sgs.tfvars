# ===================================================================================================================
# SECURITY GROUPS
# ===================================================================================================================
sgs = {
  # ---------------------------------------- Instances ---------------------------------------------------------------
  "wordpress_ec2_sg" = {
    "ec2_sg_name_suffix" = "wordpress-ec2-sg"
    "ec2_sg_description" = "Security Group for the WordPress EC2s"
  }
  # ---------------------------------------- Non Instances -----------------------------------------------------------
  "wordpress_alb_sg" = {
    "ec2_sg_name_suffix" = "wordpress-alb-sg"
    "ec2_sg_description" = "Security Group for the WordPress ALB"
  }
  "aurora_sg" = {
    "ec2_sg_name_suffix" = "aurora-sg"
    "ec2_sg_description" = "Security Group for the Agresso nonprod web application load balancer 01"
  }
  # -----------------------------------------------------------------------------------------------------------------
}
# ===================================================================================================================
# SECURITY GROUP RULES
# ===================================================================================================================
# ###################################################################################################################
# INBOUND - TCP, Single Port, CIDR range
# ###################################################################################################################
inbound_rules_tcp_sp_cidr = {
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - wordpress_alb_sg
  # -----------------------------------------------------------------------------------------------------------------
  "wordpress_alb_sg_80" = {
    "port"        = 80
    "description" = "HTTP from VPC-A"
    "my_sg"       = "wordpress_alb_sg"
    "cidr_blocks" = ["10.0.0.0/16"]
  }
  "wordpress_alb_sg_443" = {
    "port"        = 443
    "description" = "HTTPS from VPC-A"
    "my_sg"       = "wordpress_alb_sg"
    "cidr_blocks" = ["10.0.0.0/16"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - wordpress_ec2_sg
  # -----------------------------------------------------------------------------------------------------------------
  "wordpress_ec2_sg_22" = {
    "port"        = 22
    "description" = "SSH Ingress from Bastion Host"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.0.0.20/32"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - aurora_sg
  # -----------------------------------------------------------------------------------------------------------------
  "aurora_sg_3306_a" = {
    "port"        = 3306
    "description" = "SQL from Web APP 01"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.1.0.0/27"]
  }
  "aurora_sg_3306_b" = {
    "port"        = 3306
    "description" = "SQL from Web APP 02"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.1.0.32/27"]
  }
    # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - memcached_sg
  # -----------------------------------------------------------------------------------------------------------------
  "memcached_sg_11211_a" = {
    "port"        = 11211
    "description" = "SQL from Web APP 01"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.1.0.0/27"]
  }
  "aurora_sg_3306_b" = {
    "port"        = 3306
    "description" = "SQL from Web APP 02"
    "my_sg"       = "wordpress_ec2_sg"
    "cidr_blocks" = ["10.1.0.32/27"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_sg - wordpress_ec2_sg
  # -----------------------------------------------------------------------------------------------------------------
  "wordpress_ec2_sg_80" = {
    "port"        = 80
    "description" = "HTTP from WordPress ALB SG"
    "my_sg"       = "wordpress_ec2_sg"
    "source_sg"   = "wordpress_alb_sg"
  }
  "wordpress_ec2_sg_443" = {
    "port"        = 443
    "description" = "HTTPS from WordPress ALB SG"
    "my_sg"       = "wordpress_ec2_sg"
    "source_sg"   = "wordpress_alb_sg"
  }
}


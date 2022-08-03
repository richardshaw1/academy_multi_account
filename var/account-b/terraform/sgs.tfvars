# ===================================================================================================================
# SECURITY GROUPS
# ===================================================================================================================
sgs = {
  # ---------------------------------------- Instances ---------------------------------------------------------------
  "wordpress_ec2_sg" = {
    "ec2_sg_name_suffix" = "wordpress-ec2-sg"
    "ec2_sg_description" = "Security group for the WordPress EC2s"
  }
  # ---------------------------------------- Non Instances -----------------------------------------------------------
  "wordpress_alb_sg" = {
    "ec2_sg_name_suffix" = "wordpress-alb-sg"
    "ec2_sg_description" = "Security group for the WordPress ALB"
  }
  "aurora_sg" = {
    "ec2_sg_name_suffix" = "aurora-sg"
    "ec2_sg_description" = "Security group for the Aurora DB RDS cluster. Allows data transfer between Web application and RDS instance"
  }
  "memcached_sg" = {
    "ec2_sg_name_suffix" = "memcached-sg"
    "ec2_sg_description" = "Allows in-memory data store between Web application and Memcached cluster"
  }
  "efs_sg" = {
    "ec2_sg_name_suffix" = "efs-sg"
    "ec2_sg_description" = "Allows NFS access between Web App and EFS"
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
    "cidr_blocks" = ["10.0.0.8/32"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - aurora_sg
  # -----------------------------------------------------------------------------------------------------------------
  "aurora_sg_3306_a" = {
    "port"        = 3306
    "description" = "SQL from Web APP 01"
    "my_sg"       = "aurora_sg"
    "cidr_blocks" = ["10.1.0.0/27"]
  }
  "aurora_sg_3306_b" = {
    "port"        = 3306
    "description" = "SQL from Web APP 02"
    "my_sg"       = "aurora_sg"
    "cidr_blocks" = ["10.1.0.32/27"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - memcached_sg
  # -----------------------------------------------------------------------------------------------------------------
  "memcached_sg_11211_a" = {
    "port"        = 11211
    "description" = "Memcached from Web APP 01"
    "my_sg"       = "memcached_sg"
    "cidr_blocks" = ["10.1.0.0/27"]
  }
  "memcached_sg_11211_b" = {
    "port"        = 11211
    "description" = "Memcached from Web APP 02"
    "my_sg"       = "memcached_sg"
    "cidr_blocks" = ["10.1.0.32/27"]
  }
  # -----------------------------------------------------------------------------------------------------------------
  # Ingress tcp_sp_cidr - efs_sg
  # -----------------------------------------------------------------------------------------------------------------
  "efs_sg_2049_a" = {
    "port"        = 2049
    "description" = "NFS from Web APP 01"
    "my_sg"       = "efs_sg"
    "cidr_blocks" = ["10.1.0.0/27"]
  }
  "efs_sg_2049_b" = {
    "port"        = 2049
    "description" = "NFS from Web APP 02"
    "my_sg"       = "efs_sg"
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


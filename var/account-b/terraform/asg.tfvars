# ----------------------------------------------------------------------------------------------------------------------
# WordPress Launch Template and Auto Scaling Group
# ----------------------------------------------------------------------------------------------------------------------

asgs = {
  "wordpress_asg" = {
    create_asg                     = true
    asg_name                       = "wordpress-asg"
    asg_subnets                    = ["0", "1"]
    asg_max_size                   = "2"
    asg_min_size                   = "2"
    asg_desired_capacity           = "2"
    health_check_grace_period      = 300
    health_check_type              = "ELB"
    tag_project                    = "mob-academy"
    lt_resource_name               = "wordpress_lt"
    alb_target_group_resource_name = "wordpress_alb_tg"
  }
}

lts = {
  "wordpress_lt" = {
    create_lt            = true
    lt_name              = "wordpress-lt"
    lt_description       = "launch-template-for-wordpress-ec2-instances"
    instance_type        = "t2.micro"
    ami_id               = "ami-00f9fa09fc5bab650"
    volume_size          = "8"
    volume_type          = "gp2"
    lt_sgs               = ["wordpress_ec2_sg"]
    ec2_account_key_name = "mobilise-ec-2-key-pair"
  }
}
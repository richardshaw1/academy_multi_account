# ----------------------------------------------------------------------------------------------------------------------
# WordPress Launch Template and Auto Scaling Group
# ----------------------------------------------------------------------------------------------------------------------

asgs = {
  "wordpress_asg" = {
    create_asg           = "true"
    asg_name             = "wordpress-asg"
    asg_subnets          = ["0", "1"]
    asg_max_size         = "2"
    asg_min_size         = "2"
    asg_desired_capacity = "2"
    tag_project          = ""
    load_balancer        = "wordpress_alb"
    lt_resource_name     = "wordpress_lt"
  }
}

lts = {
  "wordpress_lt" = {
    create_lt            = "true"
    lt_name              = "wordpress-lt"
    instance_type        = "t2.micro"
    ami_id               = "ami-034bbb7b632c2f16c"
    iam_instance_profile = "instance-iam-profile"
    volume_size          = "8"
    volume_type          = "gp2"
    lt_sgs               = ["wordpress_ec2_sg"]
    ec2_account_key_name = ""
    user_data            = "templates/wordpress_bootstrap.sh"
  }
}
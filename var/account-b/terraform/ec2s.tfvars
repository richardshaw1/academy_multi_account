# ----------------------------------------------------------------------------------------------------------------------
# Variables for EC2 instances, EBS Volumes, elastic IPs if required and IAM Instance profiles
# ----------------------------------------------------------------------------------------------------------------------
ec2s = {  
  "wordpress_01" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-034bbb7b632c2f16c"
    instance_type               = "t2.micro"
    iam_instance_profile        = ""
    subnet_number               = 0
    private_ip                  = "10.1.0.13"
    associate_public_ip_address = false
    ec2_account_key_name        = "mobilise-ec2-key-pair"
    tag_name                    = "wordpress-ec2-01"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = ("./templates/wordpress_bootstrap.sh")
  }
    "wordpress_02" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-034bbb7b632c2f16c"
    instance_type               = "t2.micro"
    iam_instance_profile        = ""
    subnet_number               = 1
    private_ip                  = "10.1.0.43"
    associate_public_ip_address = false
    ec2_account_key_name        = "mobilise-ec2-key-pair"
    tag_name                    = "wordpress-ec2-01"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = ("./templates/wordpress_bootstrap.sh")
  }
}
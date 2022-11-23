# ======================================================================================================================
# EC2 instance variables
# ======================================================================================================================
ec2s = {
  "wordpress_01" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-00f9fa09fc5bab650"
    instance_type               = "t2.micro"
    iam_instance_profile        = ""
    subnet_number               = 0
    private_ip                  = "10.3.0.13"
    associate_public_ip_address = false
    ec2_account_key_name        = "mobilise-ec-2-key-pair"
    tag_name                    = "wordpress-ec2-01"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = "./templates/userdata/wordpress_bootstrap.sh"
  }
  "wordpress_02" = {
    create_instance             = true
    sg_names                    = ["wordpress_ec2_sg"]
    ami                         = "ami-00f9fa09fc5bab650"
    instance_type               = "t2.micro"
    iam_instance_profile        = ""
    subnet_number               = 1
    private_ip                  = "10.3.0.43"
    associate_public_ip_address = false
    ec2_account_key_name        = "mobilise-ec-2-key-pair"
    tag_name                    = "wordpress-ec2-02"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = "./templates/userdata/wordpress_bootstrap.sh"
  }
}
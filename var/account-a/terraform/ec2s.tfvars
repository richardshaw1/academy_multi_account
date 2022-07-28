ec2s = {
  "squid_proxy_01" = {
    create_instance             = true
    sg_names                    = ["squid_sg"]
    ami                         = "ami-0bd2099338bc55e6d"
    instance_type               = "t2.micro"
    iam_instance_profile        = "instance_iam_role"
    subnet_number               = 0
    private_ip                  = "10.0.0.10"
    associate_public_ip_address = true
    ec2_account_key_name        = "mobilise-rs-key-pair"
    tag_name                    = "squid-proxy-01"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = ("./templates/squid_bootstrap.sh")
  }
  "squid_proxy_02" = {
    create_instance             = true
    sg_names                    = ["squid_sg"]
    ami                         = "ami-0bd2099338bc55e6d"
    instance_type               = "t2.micro"
    iam_instance_profile        = "instance_iam_role"
    subnet_number               = 1
    private_ip                  = "10.0.0.40"
    associate_public_ip_address = true
    ec2_account_key_name        = "mobilise-rs-key-pair"
    tag_name                    = "squid-proxy-02"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
    user_data                   = ("./templates/squid_bootstrap.sh")

  }
  "bastion_host" = {
    create_instance             = true
    sg_names                    = ["ssh_from_internet"]
    ami                         = "ami-0bd2099338bc55e6d"
    instance_type               = "t2.micro"
    iam_instance_profile        = "instance_iam_role"
    subnet_number               = 0
    private_ip                  = "10.0.0.20"
    associate_public_ip_address = true
    ec2_account_key_name        = "mobilise-rs-key-pair"
    tag_name                    = "bastion-host"
    tag_project                 = "mobilise-academy"
    root_size                   = 8
    root_type                   = "gp2"
    root_encrypted              = false
    root_tag_name               = "ROOT"
  }
}



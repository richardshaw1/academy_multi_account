terraform {
  backend "s3" {
    bucket = "rs-tf-state-bucket"
    key    = "terraform-mobilise-academy/terraform.tfstate"
    region = "eu-west-2"
  }
}
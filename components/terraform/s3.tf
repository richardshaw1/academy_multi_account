resource "aws_s3_bucket" "assets" {
  bucket = "assets.rs.mobilise.academy"

  tags = {
    Name    = "mobilise-academy"
    project = "Workshop"
  }
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

/* resource "aws_s3_bucket_acl" "assets" {
  bucket = assets.rs.mobilise.academy.assets.id
  acl = "public-read-write"
} */

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket              = aws_s3_bucket.assets.id
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_versioning" "assets_versioning" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets_sse" {
  bucket = aws_s3_bucket.assets.bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_object" "object" {
  bucket                 = "assets.rs.mobilise.academy"
  key                    = "aws-certfied-cloud-practitioner"
  source                 = "/Users/richardshaw/Downloads/aws-certified-cloud-practitioner.png"

  depends_on = [
    aws_s3_bucket.assets
  ]
}


resource "aws_s3_bucket_policy" "allow_object_access_from_internet" {
  bucket = aws_s3_bucket.assets.id
  policy = file("./templates/assets_bucket.json")
}

resource "aws_s3_bucket_website_configuration" "assets" {
  bucket = aws_s3_bucket.assets.bucket
  redirect_all_requests_to {
    host_name = "https://assets.rs.mobilise.academy.s3-website.eu-west-2.amazonaws.com"
    protocol  = "http"
  }
}

resource "aws_s3_bucket_website_configuration" "assets_web_conf" {
  bucket = aws_s3_bucket.assets.bucket

  redirect_all_requests_to {
    host_name = "https://assets.rs.mobilise.academy.s3-website.eu-west-2.amazonaws.com/"
    protocol  = "https"
  }
}
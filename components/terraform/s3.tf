# =========================================================================================================================
# s3 variables
# =========================================================================================================================
variable "create_s3" {
  type        = bool
  description = "creates s3 bucket"
  default     = false
}

variable "s3_bucket_name" {
  type        = string
  description = "s3 bucket name"
  default     = ""
}

variable "s3_bucket_ac" {
  type        = string
  description = "s3 bucket assets control rule"
  default     = ""
}

variable "s3_bucket_versioning" {
  type        = string
  description = "s3 bucket versioning"
  default     = ""
}

variable "s3_bucket_sse" {
  type        = string
  description = "s3 bucket sse"
  default     = ""
}

variable "s3_bucket_hostname" {
  type        = string
  description = "s3 bucket hostname"
  default     = ""
}

variable "s3_bucket_protocol" {
  type        = string
  description = "s3 bucket protocol"
  default     = ""
}

variable "s3_bucket_object_key" {
  type        = string
  description = "s3 bucket object key"
  default     = ""
}

variable "s3_bucket_object_source" {
  type        = string
  description = "s3 bucket object source"
  default     = ""
}

# =========================================================================================================================
# resource creation
# =========================================================================================================================
# -------------------------------------------------------------------------------------------------------------------------
# s3 bucket
# -------------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "assets" {
  count         = var.create_s3 ? 1 : 0
  bucket        = var.s3_bucket_name
  force_destroy = true


  tags = merge(
    local.default_tags,
    {
      Name    = var.s3_bucket_name
      project = "workshop"
    },
  )
}

resource "aws_s3_bucket_policy" "assets_policy" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id
  policy = file("./templates/policies/assets_bucket.json")
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id

  rule {
    object_ownership = var.s3_bucket_ac
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  count               = var.create_s3 ? 1 : 0
  bucket              = aws_s3_bucket.assets[0].id
  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_versioning" "assets_versioning" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.assets[0].id
  versioning_configuration {
    status = var.s3_bucket_versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets_sse" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.assets[0].bucket

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_bucket_sse
    }
  }
}

resource "aws_s3_object" "object" {
  count = var.create_s3 ? 1 : 0

  bucket = var.s3_bucket_name
  key    = var.s3_bucket_object_key
  source = var.s3_bucket_object_source

  depends_on = [
    aws_s3_bucket.assets
  ]
}

resource "aws_s3_bucket_website_configuration" "assets" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.assets[0].bucket
  redirect_all_requests_to {
    host_name = var.s3_bucket_hostname
    protocol  = var.s3_bucket_protocol
  }
}
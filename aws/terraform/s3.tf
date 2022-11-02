
resource "aws_s3_bucket" "strapi_assets" {
  bucket = "${var.stack_name}-assets"
}

resource "aws_s3_bucket_acl" "vapi_assets_acl" {
  bucket = aws_s3_bucket.strapi_assets.bucket
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.strapi_assets.bucket
  policy = data.aws_iam_policy_document.allow_public_access.json
}

data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.strapi_assets.arn,
      "${aws_s3_bucket.strapi_assets.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vapi_assets_encryption" {
  bucket = aws_s3_bucket.strapi_assets.bucket
  rule {
    bucket_key_enabled = true
  }
}

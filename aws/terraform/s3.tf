
resource "aws_s3_bucket" "vapi_assets" {
bucket = "vallai-api--assets"
}

resource "aws_s3_bucket_acl" "vapi_assets_acl" {
for_each = var.env_names
bucket = aws_s3_bucket.vapi_assets[each.key].bucket
acl = "public-read"
}

resource "aws_s3_bucket_policy" "allow_public_access" {
for_each = var.env_names
bucket = aws_s3_bucket.vapi_assets[each.key].bucket
policy = data.aws_iam_policy_document.allow_public_access[each.key].json
}

data "aws_iam_policy_document" "allow_public_access" {
for_each = var.env_names
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
aws_s3_bucket.vapi_assets[each.key].arn,
"${aws_s3_bucket.vapi_assets[each.key].arn}/*",
]
}
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vapi_assets_encryption" {
for_each = var.env_names
bucket = aws_s3_bucket.vapi_assets[each.key].bucket
rule {
bucket_key_enabled = true
}
}

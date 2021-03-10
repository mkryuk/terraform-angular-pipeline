resource "aws_s3_bucket" "app_build" {
  depends_on    = [aws_s3_bucket.app_logs]
  bucket        = "${var.app_name}-${var.env}-build-${var.account_id}"
  acl           = "private"
  force_destroy = true

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  logging {
    target_bucket = aws_s3_bucket.app_logs.id
    target_prefix = "${var.app_domain}/app_build/"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  depends_on = [aws_s3_bucket.app_build, aws_cloudfront_origin_access_identity.origin_access_identity]
  bucket     = aws_s3_bucket.app_build.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:GetObject"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = "${aws_s3_bucket.app_build.arn}/*"
          Sid      = "cloudfront_get_object"
        },
        {
          Action = "s3:ListBucket"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = aws_s3_bucket.app_build.arn
          Sid      = "cloudfront_get_bucket"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

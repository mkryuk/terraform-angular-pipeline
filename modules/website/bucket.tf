resource "aws_s3_bucket" "bucket_site" {
  bucket        = "${var.app_name}-${var.account_id}-${var.git_repository_branch}"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "bucket_site_policy" {
  depends_on = [aws_s3_bucket.bucket_site, aws_cloudfront_origin_access_identity.origin_access_identity]
  bucket     = aws_s3_bucket.bucket_site.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action = "s3:GetObject"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = "${aws_s3_bucket.bucket_site.arn}/*"
          Sid      = "cloudfront_get_object"
        },
        {
          Action = "s3:ListBucket"
          Effect = "Allow"
          Principal = {
            AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
          }
          Resource = aws_s3_bucket.bucket_site.arn
          Sid      = "cloudfront_get_bucket"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

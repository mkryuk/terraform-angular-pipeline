resource "aws_s3_bucket" "app_source" {
  depends_on    = [aws_s3_bucket.app_logs]
  bucket        = "${var.app_name}-${var.env}-source-${var.account_id}"
  acl           = "private"
  force_destroy = true

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  logging {
    target_bucket = aws_s3_bucket.app_logs.id
    target_prefix = "${var.app_domain}/app_source/"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
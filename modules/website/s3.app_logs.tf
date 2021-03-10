# Creates bucket to store logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.app_name}-${var.env}-logs-${var.account_id}"
  acl    = "log-delivery-write"

  # Comment the following line if you are uncomfortable with Terraform destroying the bucket even if this one is not empty 
  force_destroy = true

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
## Route 53
# Provides details about the zone
data "aws_route53_zone" "main" {
  name         = var.app_domain
  private_zone = false
}

# Creates the DNS record to point on the main CloudFront distribution ID
resource "aws_route53_record" "website_cdn_root_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.app_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.app_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

## ACM (AWS Certificate Manager)
# Creates the wildcard certificate *.<yourdomain.com>
resource "aws_acm_certificate" "wildcard_website" {
  provider = aws.us-east-1 # Wilcard certificate used by CloudFront requires this specific region (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html)

  domain_name               = var.app_domain
  subject_alternative_names = ["*.${var.app_domain}"]
  validation_method         = "DNS"

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Get the ARN of the issued certificate
data "aws_acm_certificate" "wildcard_website" {
  provider = aws.us-east-1

  depends_on = [
    aws_acm_certificate.wildcard_website,
    aws_route53_record.wildcard_validation,
    aws_acm_certificate_validation.wildcard_cert,
  ]

  domain      = var.app_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

# Validates the ACM wildcard by creating a Route53 record (as `validation_method` is set to `DNS` in the aws_acm_certificate resource)
resource "aws_route53_record" "wildcard_validation" {

  for_each = {
    for dvo in aws_acm_certificate.wildcard_website.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
  ttl             = "60"
}

# Triggers the ACM wildcard certificate validation event
resource "aws_acm_certificate_validation" "wildcard_cert" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.wildcard_website.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_validation : record.fqdn]
}
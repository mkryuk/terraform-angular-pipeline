output "s3-cdn" {
  value = aws_cloudfront_distribution.site_s3_distribution.domain_name
}
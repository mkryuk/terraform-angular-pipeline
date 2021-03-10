
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/cloudfront/${aws_s3_bucket.app_build.bucket_regional_domain_name}"
}
resource "aws_cloudfront_distribution" "app_distribution" {

  depends_on = [
    aws_s3_bucket.app_build,
    aws_s3_bucket.app_logs,
    aws_cloudfront_origin_access_identity.origin_access_identity
  ]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [var.app_domain]

  comment = "${var.app_name}-${var.env}-cdn"

  origin {
    domain_name = aws_s3_bucket.app_build.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.app_build.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.app_build.bucket
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers                 = []
      query_string            = true
      query_string_cache_keys = []
      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  ordered_cache_behavior {

    path_pattern    = "*.js"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = aws_s3_bucket.app_build.id

    forwarded_values {

      query_string = true

      cookies {
        forward = "all"
      }

    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"

  }

  ordered_cache_behavior {

    path_pattern    = "*.css"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = aws_s3_bucket.app_build.id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"

  }

  ordered_cache_behavior {

    path_pattern    = "*.png"
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = aws_s3_bucket.app_build.id

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "allow-all"

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  wait_for_deployment = true

  tags = {
    Environment = "${var.app_name}-${var.env}"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn = data.aws_acm_certificate.wildcard_website.arn
    ssl_support_method  = "sni-only"
  }

  logging_config {
    bucket = aws_s3_bucket.app_logs.bucket_domain_name
    prefix = "${var.app_domain}/app_distribution/"
  }
}
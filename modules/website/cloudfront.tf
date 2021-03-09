
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "origin-access-identity/cloudfront/${aws_s3_bucket.bucket_site.bucket_regional_domain_name}"
}
resource "aws_cloudfront_distribution" "site_s3_distribution" {

  depends_on          = [aws_s3_bucket.bucket_site, aws_cloudfront_origin_access_identity.origin_access_identity]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = var.domain_names

  comment = "${var.app_name}-${var.git_repository_branch}-cdn"

  origin {
    domain_name = aws_s3_bucket.bucket_site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket_site.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.bucket_site.bucket
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

    target_origin_id = aws_s3_bucket.bucket_site.id

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

    target_origin_id = aws_s3_bucket.bucket_site.id

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

    target_origin_id = aws_s3_bucket.bucket_site.id

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
    Environment = "${var.app_name}-${var.git_repository_branch}"
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
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }

}
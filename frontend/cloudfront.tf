data "aws_acm_certificate" "jungle-meet-com" {
  domain   = "${var.domain_name}"
  provider = aws.cloudfront
  //CloudFront uses certificates from US-EAST-1 region only
  statuses = [
    "ISSUED",
  ]
}

resource "aws_cloudfront_origin_access_identity" "jungle-meet-com" {
  comment = "access-identity-www-${var.domain_name}.s3.amazonaws.com"
}

resource "aws_cloudfront_distribution" "jungle-meet-com" {
  depends_on = [
    aws_s3_bucket.www-jungle-meet-com
  ]

  origin {
    domain_name = aws_s3_bucket.www-jungle-meet-com.bucket_regional_domain_name
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.jungle-meet-com.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain_name , "www.jungle-meet.com"]

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    # https://stackoverflow.com/questions/67845341/cloudfront-s3-etag-possible-for-cloudfront-to-send-updated-s3-object-before-t
    min_ttl     = var.cloudfront_min_ttl
    default_ttl = var.cloudfront_default_ttl
    max_ttl     = var.cloudfront_max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_restriction_type
      locations = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.jungle-meet-com.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }


  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
  }

  wait_for_deployment = false
  tags                = var.tags
}

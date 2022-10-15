data "aws_route53_zone" "jungle-meet-com" {
  name         = var.domain_name
  private_zone = false
}


resource "aws_route53_record" "A-www-jungle-meet-com" {
  depends_on = [
    aws_cloudfront_distribution.jungle-meet-com
  ]

  zone_id = data.aws_route53_zone.jungle-meet-com.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.jungle-meet-com.domain_name
    zone_id = "Z2FDTNDATAQYW2"

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

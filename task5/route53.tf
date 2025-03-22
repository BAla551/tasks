resource "aws_route53_record" "cdn_record" {
  zone_id = "Z04211613N4IGF48R4C9F"  # Your Hosted Zone ID
  name    = "static-s3.balatrade.click"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

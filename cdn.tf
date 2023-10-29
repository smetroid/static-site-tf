#NOTE: most of the settings are defaults, and I did try to keep the configuration at a minimum
module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  for_each            = local.config.cdn
  aliases             = each.value.aliases
  comment             = "${each.key}-${local.env}-CloudFront"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = true

  create_monitoring_subscription = true
  create_origin_access_identity  = true
  origin_access_identities       = lookup(each.value, "origin_access_identities", {})

  # Origin key should be the Cloudfront origin name in AWS console
  origin = {
    "S3-${each.key}" = {
      domain_name           = "${each.key}-${local.env}.s3.${local.region}.amazonaws.com"
      s3_origin_config      = {}
      origin_access_control = "${each.key}-${local.env}"
    }
  }

  create_origin_access_control = true
  origin_access_control = {
    ("${each.key}-${local.env}") = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "S3-${each.key}"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true

    # This is needed in order to render the app (index.html) when hitting the cloudfront url d66ht9id7skr1.cloudfront.net, instead of d66ht9id7skr1.cloudfront.net/index.html
    function_association = {
      for fk, fv in each.value.function_association : fk => {
        # Issue: the data is looking for a lambda that does not yet exists.
        function_arn = aws_cloudfront_function.common_cdn_function[fv.lambda].arn
      }
    }
  }
  web_acl_id = module.waf_webaclv2[each.key].web_acl_arn

  # This should fix the lambda does not yet exist on a brand new terraform apply ... need to test
  depends_on = [ aws_cloudfront_function.common_cdn_function ]
}

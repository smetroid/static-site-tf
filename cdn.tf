module "cdn" {
  for_each = local.config.cdn
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  aliases = each.value.aliases

  comment             = "${each.key}-${local.env}-CloudFront"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_monitoring_subscription = true
  create_origin_access_identity = true
  origin_access_identities      = lookup(each.value, "origin_access_identities", {})

# Origin key should be the Cloudfront origin name in AWS console
  origin = {
    "S3-${each.key}" = {
      #domain_name           = origin.domain_name
      domain_name           = "${each.key}-${local.env}.s3.${local.region}.amazonaws.com"
      s3_origin_config      = {}
      origin_access_control = "${each.key}-${local.env}"
    }
  }

  #create_origin_access_control = lookup(each.value, "create_origin_access_control", false)
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
        #function_arn = data.aws_cloudfront_function.cdn_functions[fv.lambda].arn
        function_arn = aws_cloudfront_function.common_cdn_function[fv.lambda].arn
      }
    }

  }

  #depends_on = [ aws_cloudfront_function.common_cdn_function ]
}

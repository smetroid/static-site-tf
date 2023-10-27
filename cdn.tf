module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.2.1"

  for_each = local.config.cdn
  aliases = each.value.aliases

  comment             = "${local.env}-CloudFront"
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
      domain_name           = "${each.key}-${local.env}.s3.${local.region}.amazon.aws.com"
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

  logging_config = {
    bucket = "module.log_bucket.${each.key}"
    prefix = "cloudfront"
  }

  default_cache_behavior = {
    target_origin_id       = "S3-${each.key}"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true

    function_association = {
      for fk, fv in each.value.function_association : fk => {
        # Issue: the data is looking for a lambda that does not yet exists.
        #function_arn = data.aws_cloudfront_function.cdn_functions[fv.lambda].arn
        function_arn = aws_cloudfront_function.common_cdn_function[fv.lambda].arn
      }
    }

    response_headers_policy_id = try(each.value.default_cache_behavior.response_headers_policy_id, aws_cloudfront_response_headers_policy.cdn_acrhp[each.key].id)
  }
  depends_on = [ aws_cloudfront_function.common_cdn_function ]
}
resource "aws_cloudfront_function" "common_cdn_function" {
  for_each = toset(local.config.functions)
  name     = each.key
  runtime  = "cloudfront-js-1.0"
  code     = file("functions/${each.key}.html")
  publish  = true
}

resource "aws_cloudfront_response_headers_policy" "cdn_acrhp" {
  for_each = local.config.cdn
  name     = each.key
  comment  = "${each.key} ${local.env} spycloud spa specific headers"

  security_headers_config {
    strict_transport_security {
      override                   = true
      preload                    = true
      include_subdomains         = true
      access_control_max_age_sec = 63072000
    }

    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    xss_protection {
      override   = true
      protection = true
      mode_block = true
    }

    referrer_policy {
      override        = true
      referrer_policy = "same-origin"
    }

    content_security_policy {
      override                = true
      content_security_policy = lookup(each.value, "csp", "")
    }

    content_type_options {
      override = true
    }
  }
}

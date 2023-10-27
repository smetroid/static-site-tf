data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}
data "aws_cloudfront_cache_policy" "cache_policy" {
  for_each = local.config.cdn
  name     = each.value.cache_policy_name
}

data "aws_cloudfront_function" "cdn_functions" {
  for_each = local.associations
  name     = each.key
  stage    = "LIVE"
}

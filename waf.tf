
resource "aws_wafv2_ip_set" "white_list" {
  for_each = local.config.wafv2
  #count = local.config["wafv2"] == {} ? 0 : 1
  name               = "${each.key}-white-list"
  description        = "${each.key} white list"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = each.value.white_list
}

module "waf_webaclv2" {
  source  = "umotif-public/waf-webaclv2/aws"
  version = "5.1.2"

  for_each               = local.config.wafv2
  name_prefix            = each.key
  description            = "Web ACL for ${each.key} ${local.region} ${local.env}"
  allow_default_action   = each.value.allow_default_action
  scope                  = "CLOUDFRONT"
  create_alb_association = false
  visibility_config = {
    cloudwatch_metrics_enabled = false
    metric_name                = "${each.key}-waf-setup-waf-main-metrics"
    sampled_requests_enabled   = false
  }

  rules = [
    {
      name     = "white-list"
      priority = "0"
      action   = "allow"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${each.key}-${local.region}-${local.env}-white-list"
        sampled_requests_enabled   = true
      }
      ip_set_reference_statement = {
        arn = aws_wafv2_ip_set.white_list[each.key].arn
      }
    },

    # Rate limiting for security and compliance
    {
      name     = "RateLimit"
      priority = 2
      action   = "block"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "RateLimit"
        sampled_requests_enabled   = true
      }
      rate_based_statement = {
        limit              = 300
        aggregate_key_type = "IP"
      }
    },

    # Adding additional free rule groups
    {
      name            = "AWSManagedRulesAmazonIpReputationList"
      priority        = "1"
      override_action = "none"
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "AWSManagedRulesAmazonIpReputationList"
        sampled_requests_enabled   = true
      }
      managed_rule_group_statement = {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    },
  ]
}

resource "aws_cloudwatch_log_group" "waf" {
  for_each = local.config.wafv2
  # Log group name for WAF ACLs must start with aws-waf-logs-
  name              = "aws-waf-logs-${each.key}"
  retention_in_days = 14
}

resource "aws_wafv2_web_acl_logging_configuration" "waf" {
  for_each                = local.config.wafv2
  resource_arn            = module.waf_webaclv2[each.key].web_acl_arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[each.key].arn]
}

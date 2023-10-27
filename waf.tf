
resource "aws_wafv2_ip_set" "white_list" {
  for_each = local.config.wafv2
  #count = local.config["wafv2"] == {} ? 0 : 1
  name               = "${each.key}-white-list"
  description        = "${each.key} white list"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = each.value.white_list
}


module "waf-webaclv2" {
  source  = "umotif-public/waf-webaclv2/aws"
  version = "5.1.2"

  for_each               = local.config.wafv2
  name_prefix            = each.key
  description            = "Web ACL for ${each.key} ${local.region} ${local.env}"
  allow_default_action   = true
  scope                  = "REGIONAL"
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
        metric_name                = "${each.key}-${local.region}-${local.env}-white-lis"
        sampled_requests_enabled   = true
      }
      ip_set_reference_statement = {
        arn = aws_wafv2_ip_set.white_list[each.key].arn
      }
    },
  ]
}


output app_url {
  description = "Cloudfront URL to use for testing"
  value = { for k,v in local.config.cdn : k => module.cdn[k].cloudfront_distribution_domain_name }
}

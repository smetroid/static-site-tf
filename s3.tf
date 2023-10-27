#############
# S3 buckets
#############


module "spa_bucket" {
  for_each = local.config.cdn
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = each.key
  force_destroy = true
}

module "log_bucket" {
  for_each = local.config.cdn
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "logs-${each.key}"
  acl    = null
  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
    # Ref. https://github.com/terraform-providers/terraform-provider-aws/issues/12512
    # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  }]
  force_destroy = true
}

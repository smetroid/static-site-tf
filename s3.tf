#############
# S3 buckets
#############
module "spa_bucket" {
  for_each = local.config.cdn
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "~> 3.0"

  bucket        = "${each.key}-${local.env}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = local.config.cdn
  bucket   = module.spa_bucket[each.key].s3_bucket_id
  policy   = data.aws_iam_policy_document.s3_policy[each.key].json
}

data "aws_iam_policy_document" "s3_policy" {
  for_each = local.config.cdn
  # Origin Access Identities
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.spa_bucket[each.key].s3_bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = module.cdn[each.key].cloudfront_origin_access_identity_iam_arns
    }
  }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.spa_bucket[each.key].s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cdn[each.key].cloudfront_distribution_arn]
    }
  }
}
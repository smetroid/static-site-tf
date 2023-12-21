
# This particular function is a generic function used to append index.html to requests that
# do not include a file extension in the URL
# eg: it will allow the rendering of index.html to the cloudfront URL d66ht9id7skr1.cloudfront.net instead of adding d66ht9id7skr1.cloudfront.net/index.html
# 
resource "aws_cloudfront_function" "common_cdn_function" {
  for_each = toset(local.config.functions)
  name     = each.key
  runtime  = "cloudfront-js-1.0"
  code     = file("functions/${each.key}.js")
  publish  = true
}

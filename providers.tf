provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Environment = local.env
    }
  }
}


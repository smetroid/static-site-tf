locals {
  config = yamldecode(file("./config.yaml"))[terraform.workspace]
  env    = terraform.workspace
  associations = merge([
    for fk, fv in local.config.cdn : {
      for sk, sv in fv.function_association : sv.lambda => fk
    }
  ]...)

  regions = {
    "default" = "us-east-1"
  }
  region = local.regions[terraform.workspace]
}

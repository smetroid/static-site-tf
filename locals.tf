locals {
  config = yamldecode(file("./config.yaml"))[terraform.workspace]
}
provider "sakuracloud" {
  zone = var.default_zone
}

module "label" {
  source      = "cloudposse/label/null"
  namespace   = var.label["namespace"]
  stage       = var.label["stage"]
  name        = var.label["name"]
  attributes  = [var.label["namespace"], var.label["stage"], var.label["name"]]
  delimiter   = "-"
  label_order = ["namespace", "stage", "name"]
}

terraform {
  required_version = "~> 1"
  #cloud {}

  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2"
    }
  }
}

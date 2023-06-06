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
  #backend "s3" {
  #  bucket                      = "bucket-name"
  #  key                         = "02_design_pattern/terraform.tfstate"
  #  region                      = "jp-north-1"
  #  endpoint                    = "https://s3.isk01.sakurastorage.jp"
  #  skip_region_validation      = true
  #  skip_credentials_validation = true
  #  skip_metadata_api_check     = true
  #  force_path_style            = true
  #}

  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "~> 2"
    }
  }
}

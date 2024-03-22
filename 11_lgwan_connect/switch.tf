resource "sakuracloud_switch" "switch01" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch01["name"])
  description = var.switch01["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch02" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch02["name"])
  description = var.switch02["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch03" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch03["name"])
  description = var.switch03["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch04" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch04["name"])
  description = var.switch04["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch05" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch05["name"])
  description = var.switch05["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch06" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch06["name"])
  description = var.switch06["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch07" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch07["name"])
  description = var.switch07["memo"]
  tags        = module.label.attributes
}

resource "sakuracloud_switch" "switch08" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch08["name"])
  description = var.switch08["memo"]
  tags        = module.label.attributes
}


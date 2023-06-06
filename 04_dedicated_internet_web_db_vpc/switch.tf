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

resource "sakuracloud_switch" "switch01" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.switch01["name"])
  description = var.switch01["memo"]
  tags        = module.label.attributes
}

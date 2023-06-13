resource "sakuracloud_internet" "router01" {
  count = var.router01["count"]
  zone  = var.default_zone
  name  = format("%s-%s", module.label.id, var.router01["name"])

  #ネットワークマスク
  netmask = var.router01["nw_mask_len"]

  #帯域幅(Mbps単位)
  band_width = var.router01["band_width"]

  #IPv6有効化
  enable_ipv6 = var.router01["enable_ipv6"]

  description = var.router01["memo"]
  tags        = module.label.attributes
}

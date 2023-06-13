data "http" "ip_address" {
  url = "https://api.ipify.org/"
}

locals {
  allow_ip_address = trimspace(data.http.ip_address.response_body)
  protocol         = ["tcp", "tcp", "tcp", "icmp", "tcp", "udp", "fragment", "ip"]
  source_network   = [var.simple_monitor_source_network, local.allow_ip_address, "", "", "", "", "", ""]
  source_port      = ["", "", "", "", "", "", "", ""]
  destination_port = ["22", "22", "80", "", "32768-61000", "32768-61000", "", ""] # for linux
  allow            = [true, true, true, true, true, true, true, false]
}

resource "sakuracloud_packet_filter" "filter01" {
  zone        = var.default_zone
  name        = format("%s-%s", module.label.id, var.filter01["name"])
  description = var.filter01["memo"]

  dynamic "expression" {
    for_each = local.protocol
    content {
      protocol         = local.protocol[expression.key]
      source_network   = local.source_network[expression.key]
      source_port      = local.source_port[expression.key]
      destination_port = local.destination_port[expression.key]
      allow            = local.allow[expression.key]
    }
  }
}


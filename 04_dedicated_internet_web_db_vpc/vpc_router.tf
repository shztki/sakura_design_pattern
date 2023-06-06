data "http" "ip_address" {
  url = "https://api.ipify.org/"
}

resource "sakuracloud_vpc_router" "vpc_router01" {
  count       = var.vpc_router01["count"]
  zone        = var.default_zone
  name        = format("%s-%s-%03d", module.label.id, var.vpc_router01["name"], count.index + 1)
  description = var.vpc_router01["memo"]
  version     = var.vpc_router01["version"]
  tags        = module.label.attributes
  plan        = var.vpc_router01["plan"]

  internet_connection = var.vpc_router01["internet_connection"]

  public_network_interface {
    switch_id    = sakuracloud_internet.router01[0].switch_id
    vip          = sakuracloud_internet.router01[0].ip_addresses[0]
    ip_addresses = [sakuracloud_internet.router01[0].ip_addresses[1], sakuracloud_internet.router01[0].ip_addresses[2]]
    aliases      = slice(sakuracloud_internet.router01[0].ip_addresses, 3, length(sakuracloud_internet.router01[0].ip_addresses) > 19 ? 22 : length(sakuracloud_internet.router01[0].ip_addresses))
    vrid         = var.vpc_router01["vrid"]
  }

  # プライベートNICの定義(複数定義可能)
  private_network_interface {
    index        = 1
    switch_id    = sakuracloud_switch.switch01.id
    vip          = cidrhost(var.switch01["name"], var.vpc_router01["vip"])
    ip_addresses = [cidrhost(var.switch01["name"], var.vpc_router01["interface_ip1"]), cidrhost(var.switch01["name"], var.vpc_router01["interface_ip2"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch01["name"]), 0))
  }
  private_network_interface {
    index        = 2
    switch_id    = sakuracloud_switch.switch02.id
    vip          = cidrhost(var.switch02["name"], var.vpc_router01["vip"])
    ip_addresses = [cidrhost(var.switch02["name"], var.vpc_router01["interface_ip1"]), cidrhost(var.switch02["name"], var.vpc_router01["interface_ip2"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch02["name"]), 0))
  }

  # スタティックNAT(プレミアム/ハイスペックプランのみ)
  dynamic "static_nat" {
    for_each = sakuracloud_server.server01
    content {
      public_ip   = sakuracloud_internet.router01[0].ip_addresses[3 + static_nat.key]
      private_ip  = cidrhost(var.switch01["name"], var.server01["start_ip"] + static_nat.key)
      description = format("vpc_nat_%03d", static_nat.key + 1)
    }
  }

  firewall {
    interface_index = 0

    direction = "receive"
    expression {
      protocol            = "ip"
      source_network      = data.http.ip_address.response_body
      source_port         = ""
      destination_network = var.switch01["name"]
      destination_port    = ""
      allow               = true
      logging             = true
      description         = "desc"
    }
    expression {
      protocol            = "tcp"
      source_network      = ""
      source_port         = ""
      destination_network = var.switch01["name"]
      destination_port    = "80"
      allow               = true
      logging             = true
      description         = "desc"
    }
    expression {
      protocol            = "ip"
      source_network      = ""
      source_port         = ""
      destination_network = ""
      destination_port    = ""
      allow               = false
      logging             = true
      description         = "desc"
    }
  }
}

#data "http" "ip_address" {
#  url = "https://api.ipify.org/"
#}

resource "sakuracloud_vpc_router" "vpc_router02" {
  #  count       = var.vpc_router02["count"]
  zone = var.default_zone
  #  name        = format("%s-%s-%03d", module.label.id, var.vpc_router02["name"], count.index + 1)
  name        = format("%s-%s", module.label.id, var.vpc_router02["name"])
  description = var.vpc_router02["memo"]
  version     = var.vpc_router02["version"]
  tags        = module.label.attributes
  plan        = var.vpc_router02["plan"]

  internet_connection = var.vpc_router02["internet_connection"]

  # プライベートNICの定義(複数定義可能)
  private_network_interface {
    index        = 1
    switch_id    = sakuracloud_switch.switch03.id
    ip_addresses = [cidrhost(var.switch03["name"], var.vpc_router02["vip"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch03["name"]), 0))
  }
  private_network_interface {
    index        = 2
    switch_id    = sakuracloud_switch.switch04.id
    ip_addresses = [cidrhost(var.switch04["name"], var.vpc_router02["vip"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch04["name"]), 0))
  }

  # ポートフォワード
  #dynamic "port_forwarding" {
  #  for_each = range(var.server01["start_ip"], var.server01["start_ip"] + var.server01["count"])
  #  content {
  #    protocol     = "tcp"
  #    public_port  = 10022 + port_forwarding.key
  #    private_ip   = cidrhost(var.switch01["name"], var.server01["start_ip"] + port_forwarding.key)
  #    private_port = 22
  #    description  = "desc"
  #  }
  #}
  #port_forwarding {
  #  protocol     = "tcp"
  #  public_port  = 3389
  #  private_ip   = cidrhost(var.switch01["name"], var.server02["start_ip"])
  #  private_port = 3389
  #  description  = "desc"
  #}

  # スタティックルート
  static_route {
    prefix   = var.switch02["name"]
    next_hop = cidrhost(var.switch03["name"], var.localrouter01["vip"])
  }

  #wire_guard {
  #  ip_address = "192.168.31.1/24"
  #  peer {
  #    name       = "example"
  #    ip_address = "192.168.31.11"
  #    public_key = var.default_password
  #  }
  #}

  firewall {
    interface_index = 1

    direction = "receive"
    expression {
      protocol            = "tcp"
      source_network      = var.switch02["name"]
      source_port         = ""
      destination_network = var.switch04["name"]
      destination_port    = "22"
      allow               = true
      logging             = true
      description         = "desc"
    }
    expression {
      protocol            = "tcp"
      source_network      = var.switch04["name"]
      source_port         = ""
      destination_network = var.switch02["name"]
      destination_port    = "3128"
      allow               = true
      logging             = true
      description         = "desc"
    }
    expression {
      protocol            = "udp"
      source_network      = var.switch04["name"]
      source_port         = ""
      destination_network = var.switch02["name"]
      destination_port    = "53"
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

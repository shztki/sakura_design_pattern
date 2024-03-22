data "http" "ip_address" {
  url = "https://api.ipify.org/"
}

resource "sakuracloud_vpc_router" "vpc_router01" {
  #  count       = var.vpc_router01["count"]
  zone = var.default_zone
  #  name        = format("%s-%s-%03d", module.label.id, var.vpc_router01["name"], count.index + 1)
  name        = format("%s-%s", module.label.id, var.vpc_router01["name"])
  description = var.vpc_router01["memo"]
  version     = var.vpc_router01["version"]
  tags        = module.label.attributes
  plan        = var.vpc_router01["plan"]

  internet_connection = var.vpc_router01["internet_connection"]

  # プライベートNICの定義(複数定義可能)
  private_network_interface {
    index        = 1
    switch_id    = sakuracloud_switch.switch01.id
    ip_addresses = [cidrhost(var.switch01["name"], var.vpc_router01["vip"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch01["name"]), 0))
  }

  # ポートフォワード
  dynamic "port_forwarding" {
    for_each = range(var.server01["start_ip"], var.server01["start_ip"] + var.server01["count"])
    content {
      protocol     = "tcp"
      public_port  = 10022 + port_forwarding.key
      private_ip   = cidrhost(var.switch01["name"], var.server01["start_ip"] + port_forwarding.key)
      private_port = 22
      description  = "desc"
    }
  }
  #port_forwarding {
  #  protocol     = "tcp"
  #  public_port  = 3389
  #  private_ip   = cidrhost(var.switch01["name"], var.server02["start_ip"])
  #  private_port = 3389
  #  description  = "desc"
  #}

  # スタティックルート
  #static_route {
  #  prefix   = var.aws_cidr
  #  next_hop = cidrhost(var.switch01["name"], var.localrouter01["vip"])
  #}

  #wire_guard {
  #  ip_address = "192.168.31.1/24"
  #  peer {
  #    name       = "example"
  #    ip_address = "192.168.31.11"
  #    public_key = var.default_password
  #  }
  #}

  firewall {
    interface_index = 0

    direction = "receive"
    expression {
      protocol            = "tcp"
      source_network      = data.http.ip_address.response_body
      source_port         = ""
      destination_network = var.switch01["name"]
      destination_port    = "22"
      allow               = true
      logging             = true
      description         = "desc"
    }
    #expression {
    #  protocol            = "tcp"
    #  source_network      = var.office_cidr
    #  source_port         = ""
    #  destination_network = var.switch01["name"]
    #  destination_port    = "22"
    #  allow               = true
    #  logging             = true
    #  description         = "desc"
    #}
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

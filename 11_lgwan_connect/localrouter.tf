# comment out after local_router01/02
#data "sakuracloud_local_router" "peer" {
#  filter {
#    names = [format("%s-%s", module.label.id, var.localrouter01["name"])]
#  }
#}

resource "sakuracloud_local_router" "local_router01" {
  #  count       = var.localrouter01["count"]
  #  name        = format("%s-%s-%003d", module.label.id, var.localrouter01["name"], count.index + 1)
  name        = format("%s-%s", module.label.id, var.localrouter01["name"])
  description = var.localrouter01["memo"]
  tags        = module.label.attributes

  switch {
    code     = sakuracloud_switch.switch02.id
    category = "cloud"
    zone_id  = var.default_zone
  }

  network_interface {
    vip          = cidrhost(var.switch02["name"], var.localrouter01["vip"])
    ip_addresses = [cidrhost(var.switch02["name"], var.localrouter01["interface_ip1"]), cidrhost(var.switch02["name"], var.localrouter01["interface_ip2"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch02["name"]), 0))
    vrid         = var.localrouter01["vrid"]
  }

  # comment out after local_router01/02
  #peer {
  #  peer_id     = sakuracloud_local_router.local_router02.id
  #  secret_key  = sakuracloud_local_router.local_router02.secret_keys[0]
  #  description = "description"
  #}
}

resource "sakuracloud_local_router" "local_router02" {
  #  count       = var.localrouter02["count"]
  #  name        = format("%s-%s-%003d", module.label.id, var.localrouter02["name"], count.index + 1)
  name        = format("%s-%s", module.label.id, var.localrouter02["name"])
  description = var.localrouter02["memo"]
  tags        = module.label.attributes

  switch {
    code     = sakuracloud_switch.switch03.id
    category = "cloud"
    zone_id  = var.default_zone
  }

  network_interface {
    vip          = cidrhost(var.switch03["name"], var.localrouter02["vip"])
    ip_addresses = [cidrhost(var.switch03["name"], var.localrouter02["interface_ip1"]), cidrhost(var.switch03["name"], var.localrouter02["interface_ip2"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch03["name"]), 0))
    vrid         = var.localrouter02["vrid"]
  }

  static_route {
    prefix   = var.switch04["name"]
    next_hop = cidrhost(var.switch03["name"], var.vpc_router02["vip"])
  }

  # comment out after local_router01/02
  #peer {
  #  peer_id     = data.sakuracloud_local_router.peer.id
  #  secret_key  = data.sakuracloud_local_router.peer.secret_keys[0]
  #  description = "description"
  #}
}

resource "sakuracloud_local_router" "local_router03" {
  #  count       = var.localrouter03["count"]
  #  name        = format("%s-%s-%003d", module.label.id, var.localrouter03["name"], count.index + 1)
  name        = format("%s-%s", module.label.id, var.localrouter03["name"])
  description = var.localrouter03["memo"]
  tags        = module.label.attributes

  switch {
    code     = sakuracloud_switch.switch08.id
    category = "cloud"
    zone_id  = var.default_zone
  }

  network_interface {
    vip          = cidrhost(var.switch08["name"], var.localrouter03["vip"])
    ip_addresses = [cidrhost(var.switch08["name"], var.localrouter03["interface_ip1"]), cidrhost(var.switch08["name"], var.localrouter03["interface_ip2"])]
    netmask      = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch08["name"]), 0))
    vrid         = var.localrouter03["vrid"]
  }

  # connect to logwan_connect's local_router
  #peer {
  #  peer_id     = var.service_local_router_id
  #  secret_key  = var.service_local_router_key
  #  description = "description"
  #}
}


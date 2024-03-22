resource "sakuracloud_server" "server03" {
  count            = var.server03["count"]
  zone             = var.default_zone
  name             = format("%s-%s%03d", module.label.id, var.server03["name"], count.index + 1)
  disks            = [element(sakuracloud_disk.disk03.*.id, count.index)]
  core             = var.server03["core"]
  memory           = var.server03["memory"]
  commitment       = var.server03["commitment"]
  interface_driver = var.server03["interface_driver"]

  network_interface {
    upstream = sakuracloud_switch.switch07.id
  }
  network_interface {
    upstream = sakuracloud_switch.switch06.id
  }

  disk_edit_parameter {
    ip_address      = cidrhost(var.switch07["name"], var.server03["start_ip"] + count.index)
    gateway         = cidrhost(var.switch07["name"], var.vpc_router04["vip1"])
    netmask         = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch07["name"]), 0))
    hostname        = format("%s-%s-%03d", module.label.id, var.server03["name"], count.index + 1)
    ssh_key_ids     = [sakuracloud_ssh_key_gen.sshkey01.id]
    password        = var.default_password
    disable_pw_auth = var.server03["disable_pw_auth"]
    note {
      id = var.server03["os"] == "ubuntu20" || var.server03["os"] == "ubuntu22" ? sakuracloud_note.init_note02.id : sakuracloud_note.init_note01.id
      variables = {
        user_name   = "sakura-user"
        sudo_nopass = "yes"
        firewall    = "no"
        #httpd           = "yes"
        eth1_ip         = format("%s/%s", cidrhost(var.switch06["name"], var.server03["start_ip"] + count.index), element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch06["name"]), 0))
        route1_prefix1  = var.switch05["name"]
        route1_gateway1 = cidrhost(var.switch06["name"], var.vpc_router03["vip"])
        #update      = "yes"
      }
    }
  }

  description = format("%s%03d", var.server03["memo"], count.index + 1)
  tags        = concat(var.server_add_tag, module.label.attributes, [var.group_add_tag[count.index % length(var.group_add_tag)]])
  lifecycle {
    create_before_destroy = true
  }
}


resource "sakuracloud_server" "server01" {
  count            = var.server01["count"]
  zone             = var.default_zone
  name             = format("%s-%s%03d", module.label.id, var.server01["name"], count.index + 1)
  disks            = [element(sakuracloud_disk.disk01.*.id, count.index)]
  core             = var.server01["core"]
  memory           = var.server01["memory"]
  commitment       = var.server01["commitment"]
  interface_driver = var.server01["interface_driver"]

  network_interface {
    upstream = sakuracloud_switch.switch01.id
  }

  disk_edit_parameter {
    ip_address      = cidrhost(var.switch01["name"], var.server01["start_ip"] + count.index)
    gateway         = cidrhost(var.switch01["name"], var.vpc_router01["vip"])
    netmask         = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch01["name"]), 0))
    hostname        = format("%s-%s-%03d", module.label.id, var.server01["name"], count.index + 1)
    ssh_key_ids     = [sakuracloud_ssh_key_gen.sshkey01.id]
    password        = var.default_password
    disable_pw_auth = var.server01["disable_pw_auth"]
    note {
      id = var.server01["os"] == "ubuntu20" || var.server01["os"] == "ubuntu22" ? sakuracloud_note.init_note02.id : sakuracloud_note.init_note01.id
      variables = {
        user_name   = "sakura-user"
        sudo_nopass = "yes"
        firewall    = "no"
      }
    }
  }

  description = format("%s%03d", var.server01["memo"], count.index + 1)
  tags        = concat(var.server_add_tag, module.label.attributes, [var.group_add_tag[count.index % length(var.group_add_tag)]])
  lifecycle {
    create_before_destroy = true
  }
}


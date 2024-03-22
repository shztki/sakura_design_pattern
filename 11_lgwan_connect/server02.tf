resource "sakuracloud_server" "server02" {
  count            = var.server02["count"]
  zone             = var.default_zone
  name             = format("%s-%s%03d", module.label.id, var.server02["name"], count.index + 1)
  disks            = [element(sakuracloud_disk.disk02.*.id, count.index)]
  core             = var.server02["core"]
  memory           = var.server02["memory"]
  commitment       = var.server02["commitment"]
  interface_driver = var.server02["interface_driver"]

  network_interface {
    upstream = sakuracloud_switch.switch05.id
  }
  network_interface {
    upstream = sakuracloud_switch.switch04.id
  }

  disk_edit_parameter {
    ip_address      = cidrhost(var.switch05["name"], var.server02["start_ip"] + count.index)
    gateway         = cidrhost(var.switch05["name"], var.vpc_router03["vip"])
    netmask         = tostring(element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch05["name"]), 0))
    hostname        = format("%s-%s-%03d", module.label.id, var.server02["name"], count.index + 1)
    ssh_key_ids     = [sakuracloud_ssh_key_gen.sshkey01.id]
    password        = var.default_password
    disable_pw_auth = var.server02["disable_pw_auth"]
    note {
      id = var.server02["os"] == "ubuntu20" || var.server02["os"] == "ubuntu22" ? sakuracloud_note.init_note02.id : sakuracloud_note.init_note01.id
      variables = {
        user_name   = "sakura-user"
        sudo_nopass = "yes"
        firewall    = "no"
        #httpd           = "yes"
        eth1_ip         = format("%s/%s", cidrhost(var.switch04["name"], var.server02["start_ip"] + count.index), element(regex("^\\d+.\\d+.\\d+.\\d+/(\\d+)", var.switch04["name"]), 0))
        route1_prefix1  = var.switch02["name"]
        route1_gateway1 = cidrhost(var.switch04["name"], var.vpc_router02["vip"])
        #update      = "yes"
      }
    }
  }

  description = format("%s%03d", var.server02["memo"], count.index + 1)
  tags        = concat(var.server_add_tag, module.label.attributes, [var.group_add_tag[count.index % length(var.group_add_tag)]])
  lifecycle {
    create_before_destroy = true
  }
}


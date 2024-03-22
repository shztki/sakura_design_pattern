resource "sakuracloud_ssh_key_gen" "sshkey01" {
  name        = format("%s-%s", module.label.id, var.sshkey01["name"])
  description = var.sshkey01["memo"]
}


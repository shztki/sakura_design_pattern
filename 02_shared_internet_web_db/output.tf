output "ssh_public_key" {
  value = sakuracloud_ssh_key_gen.sshkey01.public_key
}
output "ssh_private_key" {
  value = sakuracloud_ssh_key_gen.sshkey01.private_key
}
output "server01_ip" {
  value = sakuracloud_server.server01.*.ip_address
}
output "server02_ip" {
  value = sakuracloud_server.server02.*.ip_address
}

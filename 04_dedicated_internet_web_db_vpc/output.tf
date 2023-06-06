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
output "vpc_router01_ip" {
  value = sakuracloud_vpc_router.vpc_router01.*.public_ip
}
output "router_ip_addresses" {
  value = sakuracloud_internet.router01.*.ip_addresses
}


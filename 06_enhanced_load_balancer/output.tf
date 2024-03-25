output "ssh_public_key" {
  value = sakuracloud_ssh_key_gen.sshkey01.public_key
}
output "ssh_private_key" {
  sensitive = true
  value     = sakuracloud_ssh_key_gen.sshkey01.private_key
}
output "server01_ip" {
  value = sakuracloud_server.server01.*.ip_address
}
#output "elb01_vip" {
#  value = sakuracloud_proxylb.elb01.vip
#}
output "elb01_fqdn" {
  value = sakuracloud_proxylb.elb01.fqdn
}
output "elb01_proxy_networks" {
  value = sakuracloud_proxylb.elb01.proxy_networks
}


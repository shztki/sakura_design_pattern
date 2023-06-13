locals {
  index_servers = {
    for n in range(var.server01["count"]) : n => n + 1
  }
}

resource "sakuracloud_proxylb" "elb01" {
  region         = var.elb01["region"]
  name           = format("%s-%s.%s", module.label.id, var.elb01["name"], var.my_domain)
  plan           = var.elb01["plan"]
  vip_failover   = var.elb01["vip_failover"]
  sticky_session = var.elb01["sticky_session"]
  gzip           = var.elb01["gzip"]
  timeout        = var.elb01["timeout"]
  proxy_protocol = var.elb01["proxy_protocol"]
  description    = var.elb01["memo"]
  tags           = module.label.attributes

  health_check {
    protocol   = "http"
    path       = "/"
    delay_loop = 10
  }

  bind_port {
    proxy_mode = "http"
    port       = 80
    #redirect_to_https = true
  }
  #bind_port {
  #  proxy_mode    = "https"
  #  port          = 443
  #  support_http2 = true
  #  #ssl_policy    = "TLS-1-2-2021-06" # TLS-1-2-2019-04/TLS-1-2-2021-06/TLS-1-3-2021-06/TLS-1-0-2021-12
  #}

  dynamic "server" {
    for_each = local.index_servers
    #for_each = sakuracloud_server.server01
    content {
      ip_address = sakuracloud_internet.router01[0].ip_addresses[server.key]
      #ip_address = server.value.ip_address
      port = 80
    }
  }

}

#resource "sakuracloud_proxylb_acme" "cert01" {
#  proxylb_id  = sakuracloud_proxylb.elb01.id
#  accept_tos  = true
#  common_name = format("%s.%s", var.elb01["name"], var.my_domain)
#  #subject_alt_names = ["www1.example.com"]
#  update_delay_sec = 120
#}


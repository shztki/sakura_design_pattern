resource "sakuracloud_simple_monitor" "monitor01_http" {
  count              = var.server01["count"]
  target             = element(sakuracloud_server.server01.*.ip_address, count.index)
  delay_loop         = 60 # 60 - 3600
  timeout            = 10 # 1 - 30
  max_check_attempts = 3  # 1 - 10
  retry_interval     = 10 # 10 - 3600
  enabled            = true
  description        = "desc"
  tags               = module.label.attributes

  health_check {
    protocol = "http" # http/https/ping/tcp/dns/ssh/smtp/pop3/snmp/sslcertificate
    #port     = 80     # optional
    path   = "/index.html"
    status = "200"
  }

  notify_email_enabled = false
  notify_email_html    = false
  notify_interval      = 2 # 1 - 72 hours
  notify_slack_enabled = false
}

resource "sakuracloud_simple_monitor" "monitor01_ping" {
  count              = var.server01["count"]
  target             = element(sakuracloud_server.server01.*.ip_address, count.index)
  delay_loop         = 60 # 60 - 3600
  max_check_attempts = 3  # 1 - 10
  retry_interval     = 10 # 10 - 3600
  enabled            = true
  description        = "desc"
  tags               = module.label.attributes

  health_check {
    protocol = "ping" # http/https/ping/tcp/dns/ssh/smtp/pop3/snmp/sslcertificate
  }

  notify_email_enabled = false
  notify_email_html    = false
  notify_interval      = 2 # 1 - 72 hours
  notify_slack_enabled = false
}

resource "sakuracloud_simple_monitor" "monitor01_ssh" {
  count              = var.server01["count"]
  target             = element(sakuracloud_server.server01.*.ip_address, count.index)
  delay_loop         = 60 # 60 - 3600
  timeout            = 10 # 1 - 30
  max_check_attempts = 3  # 1 - 10
  retry_interval     = 10 # 10 - 3600
  enabled            = true
  description        = "desc"
  tags               = module.label.attributes

  health_check {
    protocol = "ssh" # http/https/ping/tcp/dns/ssh/smtp/pop3/snmp/sslcertificate
    #port     = 22     # optional
  }

  notify_email_enabled = false
  notify_email_html    = false
  notify_interval      = 2 # 1 - 72 hours
  notify_slack_enabled = false
}


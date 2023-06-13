variable "default_zone" {
  default = "tk1b" # tk1b, is1b # tk1a, is1a
}

variable "zones" {
  default = ["tk1b"] # tk1b, is1b, # tk1a, is1a
}

variable "default_password" {}
variable "my_domain" {
  default = "example.com"
}

variable "label" {
  default = {
    namespace = "sakuracloud"
    stage     = "dev"
    name      = "designpattern"
  }
}

variable "server_add_tag" {
  default = ["@auto-reboot"]
}

variable "group_add_tag" {
  default = ["@group=a", "@group=b", "@group=c", "@group=d"]
}

variable "sshkey01" {
  default = {
    name = "sshkey01"
    memo = "example"
  }
}

variable "filter01" {
  default = {
    name = "app-filter"
    memo = "example"
  }
}

variable "disk01" {
  default = {
    name      = "app-disk"
    size      = 20    # min win:100 / linux:20
    plan      = "ssd" # ssd or hdd
    connector = "virtio"
    memo      = "example"
  }
}

variable "server01" {
  default = {
    os               = "rocky9" # miracle8/9, alma8/9, rocky8/9, ubuntu20/22
    count            = 2
    core             = 1
    memory           = 1
    commitment       = "standard" # "dedicatedcpu"
    interface_driver = "virtio"
    name             = "app"
    memo             = "example"
    disable_pw_auth  = true
    start_ip         = 10
  }
}

variable "init_script01" {
  default = {
    name  = "rhel_init"
    class = "shell" # shell or yaml_cloud_config
    file  = "userdata/rhel_init.sh"
  }
}

variable "init_script02" {
  default = {
    name  = "ubuntu_init"
    class = "shell" # shell or yaml_cloud_config
    file  = "userdata/ubuntu_init.sh"
  }
}

variable "elb01" {
  default = {
    region         = "tk1" # is1 or tk1 or anycast
    name           = "www"
    memo           = "example"
    plan           = 100
    vip_failover   = true # dns is true:fqdn or false:vip
    sticky_session = false
    gzip           = true
    timeout        = 10
    proxy_protocol = false
  }
}

variable "router01" {
  default = {
    count       = 1
    name        = "router"
    nw_mask_len = 28
    band_width  = 100
    enable_ipv6 = false
    memo        = "example"
  }
}


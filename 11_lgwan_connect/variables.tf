# environmental variables
variable "default_password" {}
#variable "office_cidr" {}
#variable "service_local_router_id" {}
#variable "service_local_router_key" {}

variable "default_zone" {
  default = "is1b" # tk1b, is1b # tk1a, is1a
}

variable "zones" {
  default = ["is1b"] # tk1b, is1b, # tk1a, is1a
}

variable "label" {
  default = {
    namespace = "sakuracloud"
    stage     = "dev"
    name      = "lgwanconnect"
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

variable "disk01" {
  default = {
    name      = "internet"
    size      = 20    # min win:100 / linux:20
    plan      = "ssd" # ssd or hdd
    connector = "virtio"
    memo      = "example"
  }
}

variable "disk02" {
  default = {
    name      = "gateway"
    size      = 20    # min win:100 / linux:20
    plan      = "ssd" # ssd or hdd
    connector = "virtio"
    memo      = "example"
  }
}

variable "disk03" {
  default = {
    name      = "lgwan"
    size      = 20    # min win:100 / linux:20
    plan      = "ssd" # ssd or hdd
    connector = "virtio"
    memo      = "example"
  }
}

variable "server01" {
  default = {
    os               = "rocky9" # miracle8/9, alma8/9, rocky8/9, ubuntu20/22
    count            = 1
    core             = 1
    memory           = 1
    commitment       = "standard" # "dedicatedcpu"
    interface_driver = "virtio"
    name             = "internet"
    memo             = "example"
    disable_pw_auth  = true
    start_ip         = 10
  }
}

variable "server02" {
  default = {
    os               = "rocky9" # miracle8/9, alma8/9, rocky8/9, ubuntu20/22
    count            = 1
    core             = 1
    memory           = 1
    commitment       = "standard" # "dedicatedcpu"
    interface_driver = "virtio"
    name             = "gateway"
    memo             = "example"
    disable_pw_auth  = true
    start_ip         = 10
  }
}

variable "server03" {
  default = {
    os               = "rocky9" # miracle8/9, alma8/9, rocky8/9, ubuntu20/22
    count            = 1
    core             = 1
    memory           = 1
    commitment       = "standard" # "dedicatedcpu"
    interface_driver = "virtio"
    name             = "lgwan"
    memo             = "example"
    disable_pw_auth  = true
    start_ip         = 2
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

variable "switch01" {
  default = {
    name = "192.168.1.0/24"
    memo = "example"
  }
}

variable "switch02" {
  default = {
    name = "192.168.2.0/24"
    memo = "example"
  }
}

variable "switch03" {
  default = {
    name = "192.168.3.0/24"
    memo = "example"
  }
}

variable "switch04" {
  default = {
    name = "192.168.4.0/24"
    memo = "example"
  }
}

variable "switch05" {
  default = {
    name = "192.168.5.0/24"
    memo = "example"
  }
}

variable "switch06" {
  default = {
    name = "192.168.6.0/24"
    memo = "example"
  }
}

variable "switch07" {
  default = {
    name = "10.50.76.0/27"
    memo = "example"
  }
}

variable "switch08" {
  default = {
    name = "10.50.79.0/29"
    memo = "example"
  }
}

variable "vpc_router01" {
  default = {
    count               = 1
    name                = "internet"
    memo                = "example"
    version             = 2
    plan                = "standard"
    internet_connection = true
    vip                 = 254
  }
}

variable "vpc_router02" {
  default = {
    count               = 1
    name                = "gateway-internet"
    memo                = "example"
    version             = 2
    plan                = "standard"
    internet_connection = false
    vip                 = 254
  }
}

variable "vpc_router03" {
  default = {
    count               = 1
    name                = "gateway-lgwan"
    memo                = "example"
    version             = 2
    plan                = "standard"
    internet_connection = false
    vip                 = 254
  }
}

variable "vpc_router04" {
  default = {
    count               = 1
    name                = "lgwan"
    memo                = "example"
    version             = 2
    plan                = "standard"
    internet_connection = false
    vip1                = 1
    vip2                = 4
  }
}

variable "localrouter01" {
  default = {
    count         = 1
    name          = "internet"
    memo          = "example"
    vip           = 1
    interface_ip1 = 2
    interface_ip2 = 3
    vrid          = 255
  }
}

variable "localrouter02" {
  default = {
    count         = 1
    name          = "gateway"
    memo          = "example"
    vip           = 1
    interface_ip1 = 2
    interface_ip2 = 3
    vrid          = 255
  }
}

variable "localrouter03" {
  default = {
    count         = 1
    name          = "lgwan"
    memo          = "example"
    vip           = 1
    interface_ip1 = 2
    interface_ip2 = 3
    vrid          = 255
  }
}


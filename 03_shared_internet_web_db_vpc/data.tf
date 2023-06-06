data "sakuracloud_archive" "miracle8" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-miracle", "miracle-8-latest"]
  }
}

data "sakuracloud_archive" "miracle9" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-miracle", "miracle-9-latest"]
  }
}

data "sakuracloud_archive" "alma8" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-alma", "alma-8-latest"]
  }
}

data "sakuracloud_archive" "alma9" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-alma", "alma-9-latest"]
  }
}

data "sakuracloud_archive" "rocky8" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-rocky", "rocky-8-latest"]
  }
}

data "sakuracloud_archive" "rocky9" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-rocky", "rocky-9-latest"]
  }
}

data "sakuracloud_archive" "ubuntu20" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-ubuntu", "ubuntu-20.04-latest"]
  }
}

data "sakuracloud_archive" "ubuntu22" {
  for_each = toset(var.zones)
  zone     = each.value
  filter {
    tags = ["distro-ubuntu", "ubuntu-22.04-latest"]
  }
}

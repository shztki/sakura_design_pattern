resource "sakuracloud_disk" "disk03" {
  count             = var.server03["count"]
  zone              = var.default_zone
  name              = format("%s-%s-%03d", module.label.id, var.disk03["name"], count.index + 1)
  source_archive_id = var.server03["os"] == "ubuntu20" ? data.sakuracloud_archive.ubuntu20[var.default_zone].id : var.server03["os"] == "ubuntu22" ? data.sakuracloud_archive.ubuntu22[var.default_zone].id : var.server03["os"] == "alma8" ? data.sakuracloud_archive.alma8[var.default_zone].id : var.server03["os"] == "rocky8" ? data.sakuracloud_archive.rocky8[var.default_zone].id : var.server03["os"] == "miracle8" ? data.sakuracloud_archive.miracle8[var.default_zone].id : var.server03["os"] == "alma9" ? data.sakuracloud_archive.alma9[var.default_zone].id : var.server03["os"] == "rocky9" ? data.sakuracloud_archive.rocky9[var.default_zone].id : data.sakuracloud_archive.miracle9[var.default_zone].id
  plan              = var.disk03["plan"]
  connector         = var.disk03["connector"]
  size              = var.disk03["size"]
  tags              = module.label.attributes
  description       = format("%s%03d", var.disk03["memo"], count.index + 1)
}


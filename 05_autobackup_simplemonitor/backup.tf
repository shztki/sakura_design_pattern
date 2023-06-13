resource "sakuracloud_auto_backup" "backup01" {
  count          = var.server01["count"]
  name           = format("%s-%s-%03d", module.label.id, var.backup01["name"], count.index + 1)
  disk_id        = element(sakuracloud_disk.disk01.*.id, count.index)
  weekdays       = var.backup01["weekdays"]
  max_backup_num = var.backup01["max_backup_num"]
  tags           = module.label.attributes
  description    = format("%s%03d", var.backup01["memo"], count.index + 1)
}


output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}

output "app_internal_ip" {
  value = "${module.app.app_internal_ip}"
}

output "db_ext_ip" {
  value = "${module.db.db_ext_ip}"
}

output "db_int_ip" {
  value = "${module.db.db_int_ip}"
}

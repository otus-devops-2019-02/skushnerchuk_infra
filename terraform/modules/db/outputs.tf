output "db_ext_ip" {
  value = "${google_compute_instance.db.network_interface.0.access_config.0.nat_ip}"
}

# Внутренний IP машины с базой
# Приложение будем натравливать именно на него, а не внешний IP
output "db_int_ip" {
  value = "${google_compute_instance.db.network_interface.0.network_ip}"
}

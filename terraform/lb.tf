#
# Пример организации балансировки нагрузки
#

# Описание healthcheck для проверки активности инстансов на порту puma-server
resource "google_compute_http_health_check" "default" {
  name               = "healthcheck"
  request_path       = "/"
  port               = "9292"
  timeout_sec        = 1
  check_interval_sec = 1
}

# Описание точки сборки создаваемых инстансов в единый пул
resource "google_compute_target_pool" "default" {
  name = "instances"

  instances = [
    "${google_compute_instance.app.*.self_link}",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.self_link}",
  ]
}

# Описание правила для 
resource "google_compute_forwarding_rule" "default" {
  name                  = "lbfwdrule"
  load_balancing_scheme = "EXTERNAL"
  target                = "${google_compute_target_pool.default.self_link}"
}

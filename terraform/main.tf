terraform {
  required_version = ">=0.11.7, <0.12"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app${count.index}"
  machine_type = "f1-micro"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  count        = "${var.instances_count}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

# Пример добавления нового ключа в метаданные проекта GCP
# Оставлен в качетсве примера еще одного способа добавления ключа
# Будет перезаписан при обработке ресурса ниже
resource "google_compute_project_metadata_item" "ssh_1" {
  key   = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}

# Пример добавления нескольких ключей в метаданные проекта
# Данные, добавленные через google_compute_project_metadata_item
# выше, БУДУТ ПЕРЕЗАПИСАНЫ
resource "google_compute_project_metadata" "ssh_keys" {
  metadata {
    ssh-keys = <<EOF
    appuser1:${trimspace(file(var.public_key_path))}
    appuser2:${trimspace(file(var.public_key_path))}
    appuser3:${trimspace(file(var.public_key_path))}
    appuser4:${trimspace(file(var.public_key_path))}
EOF
  }
}

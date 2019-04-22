variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the private key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "db_int_ip" {
  description = "Internal IP address of database instance"
}

variable "need_deploy" {
  description = "Condition for app deploing"
}

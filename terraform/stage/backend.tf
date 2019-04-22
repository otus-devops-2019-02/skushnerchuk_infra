terraform {
  backend "gcs" {
    bucket = "bs-stage"
    prefix = "terraform/state"
  }
}

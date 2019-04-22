terraform {
  backend "gcs" {
    bucket = "bs-prod"
    prefix = "terraform/state"
  }
}

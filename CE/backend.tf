terraform {
  backend "gcs" {
    bucket = "is-csto-terrafom-deploy"
    prefix = "tfstate/compute/dev"
  }
}
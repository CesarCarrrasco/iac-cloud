terraform {
  backend "gcs" {
    bucket = "is-csto-terrafom-deploy"
    prefix = "tfstate/cloudsql-psc/dev"
  }

  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.15.0"
    }
  }
}

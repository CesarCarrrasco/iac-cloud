terraform {
  backend "gcs" {
    bucket = "REEMPLAZA_BUCKET_TFSTATE"
    prefix = "tfstate/cloudsql-psc/gccspsp50-mlflow-prd"
  }

  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.15.0"
    }
  }
}

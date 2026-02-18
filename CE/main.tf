terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Para impersonación (cuando la uses):
# export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT="is-sa-tf-infra@is-architecture.iam.gserviceaccount.com"
provider "google" {}

locals {
  # Normalizamos a minúsculas + quitamos espacios extremos
  normalized_vms = {
    for k, vm in var.vms : k => merge(vm, {
      environment = lower(trimspace(vm.environment))
      application = lower(trimspace(vm.application))
      ticket      = lower(trimspace(vm.ticket))
    })
  }
}

resource "google_compute_instance" "vm" {
  for_each = local.normalized_vms

  project      = each.value.project_id
  zone         = each.value.zone
  name         = each.value.instance_name
  machine_type = each.value.machine_type

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
    hostname    = each.value.instance_name
    resource    = "ce"
    environment = each.value.environment
    application = each.value.application
    ticket      = each.value.ticket
  }

  boot_disk {
    auto_delete = true
    device_name = each.value.instance_name

    initialize_params {
      image = each.value.boot_image
      size  = each.value.boot_disk_size_gb
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    network_ip = each.value.network_ip
    stack_type = "IPV4_ONLY"
    subnetwork = each.value.subnetwork_self_link
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  # Runtime SA de la VM (identidad con la que la VM llamará APIs)
  service_account {
    email  = each.value.runtime_sa_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }
}


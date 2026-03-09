terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {}

locals {
  env_defaults = {
    dev = {
      project_id           = "is-development-389114"
      zone                 = "us-east1-b"
      subnetwork_self_link = "projects/shared-vpc-383515/regions/us-east1/subnetworks/is-snet-dev-core-is-vpc-desarrollo-shared-vpc"
      runtime_sa_email     = "844194900662-compute@developer.gserviceaccount.com"
    }

    uat = {
      project_id           = "is-staging-408920"
      zone                 = "us-east1-b"
      subnetwork_self_link = "projects/shared-vpc-383515/regions/us-east1/subnetworks/is-snet-uat-core-is-vpc-uat-shared-vpc"
      runtime_sa_email     = "697487592519-compute@developer.gserviceaccount.com"
    }

    prd = {
      project_id           = "is-production-384419"
      zone                 = "us-east1-b"
      subnetwork_self_link = "projects/shared-vpc-383515/regions/us-east1/subnetworks/is-snet-prd-core-is-vpc-prd-shared-vpc"
      runtime_sa_email     = "587328915428-compute@developer.gserviceaccount.com"
    }
  }

  os_profiles = {
    rocky9 = {
      boot_image   = "projects/rocky-linux-cloud/global/images/family/rocky-linux-9-optimized-gcp"
      machine_type = "e2-small"
      os_family    = "linux"
    }

    ubuntu2404 = {
      boot_image   = "projects/ubuntu-os-cloud/global/images/family/ubuntu-minimal-2404-lts-amd64"
      machine_type = "e2-small"
      os_family    = "linux"
    }

    win2022 = {
      boot_image   = "projects/windows-cloud/global/images/family/windows-2022"
      machine_type = "e2-medium"
      os_family    = "windows"
    }
  }

  normalized_vms = {
    for k, vm in var.vms :
    lower(trimspace(k)) => {
      instance_name     = lower(trimspace(k))
      environment       = lower(trimspace(vm.environment))
      os_profile        = lower(trimspace(vm.os_profile))
      application       = lower(trimspace(vm.application))
      ticket            = lower(trimspace(vm.ticket))
      boot_disk_size_gb = vm.boot_disk_size_gb
      network_ip        = trimspace(vm.network_ip)
      labels            = { for lk, lv in vm.labels : lower(trimspace(lk)) => lower(trimspace(lv)) }
    }
  }

  resolved_vms = {
    for k, vm in local.normalized_vms :
    k => merge(
      vm,
      local.env_defaults[vm.environment],
      local.os_profiles[vm.os_profile],
      {
        labels = merge(
          vm.labels,
          {
            goog-ec-src = "vm_add-tf"
            hostname    = vm.instance_name
            resource    = "ce"
            environment = vm.environment
            application = vm.application
            ticket      = vm.ticket
            os_profile  = vm.os_profile
          }
        )
      }
    )
  }
}

resource "google_compute_instance" "vm" {
  for_each = local.resolved_vms

  project      = each.value.project_id
  zone         = each.value.zone
  name         = each.value.instance_name
  machine_type = each.value.machine_type

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = each.value.labels

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
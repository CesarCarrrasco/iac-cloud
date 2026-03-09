variable "vms" {
  description = "Mapa de VMs. El ambiente resuelve project_id/zone/subnetwork/runtime_sa_email y os_profile resuelve boot_image/machine_type."

  type = map(object({
    environment       = string
    os_profile        = string
    application       = string
    ticket            = string
    boot_disk_size_gb = number
    network_ip        = string
    labels            = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      contains(["dev", "uat", "prd"], lower(trimspace(vm.environment)))
    ])
    error_message = "environment debe ser dev, uat o prd."
  }

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      contains(["rocky9", "ubuntu2404", "win2022"], lower(trimspace(vm.os_profile)))
    ])
    error_message = "os_profile debe ser rocky9, ubuntu2404 o win2022."
  }

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", lower(trimspace(vm_name))))
    ])
    error_message = "El nombre de la VM (clave del mapa vms) debe tener solo minúsculas, números y guiones, con formato válido de Compute Engine."
  }

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      can(regex("^[a-z0-9_-]{1,63}$", lower(trimspace(vm.application))))
    ])
    error_message = "application debe tener formato válido para label."
  }

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      can(regex("^[a-z0-9_-]{1,63}$", lower(trimspace(vm.ticket))))
    ])
    error_message = "ticket debe tener formato válido para label."
  }

  validation {
    condition = alltrue([
      for vm_name, vm in var.vms :
      vm.boot_disk_size_gb >= 20 && vm.boot_disk_size_gb <= 2048
    ])
    error_message = "boot_disk_size_gb debe estar entre 20 y 2048."
  }
}
variable "vms" {
  description = "Mapa de VMs a crear. environment/application/ticket se normalizan a minúsculas en labels."
  type = map(object({
    project_id    = string
    zone          = string
    instance_name = string

    environment = string
    application = string
    ticket      = string

    boot_image        = string
    boot_disk_size_gb = number
    machine_type      = string

    network_ip           = string
    subnetwork_self_link = string

    runtime_sa_email = string
  }))

  validation {
    condition = alltrue([
      for _, vm in var.vms :
      # instance_name: GCE name (lowercase letters, numbers, hyphen; 1..63)
      can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", vm.instance_name)) &&

      # environment/application: valid label AFTER normalizar
      can(regex("^[a-z0-9_-]{1,63}$", lower(trimspace(vm.environment)))) &&
      can(regex("^[a-z0-9_-]{1,63}$", lower(trimspace(vm.application)))) &&

      # ticket: sr- + 4..6 dígitos AFTER normalizar
      can(regex("^sr-[0-9]{4,6}$", lower(trimspace(vm.ticket)))) &&

      # disk bounds
      vm.boot_disk_size_gb >= 20 && vm.boot_disk_size_gb <= 2048
    ])
    error_message = "Validación falló: ticket debe ser sr-#### (4..6 dígitos). environment/application deben ser labels válidos."
  }
}


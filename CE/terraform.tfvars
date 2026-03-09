vms = {
  gccelxwsu15-test02 = {                        ## Nombre de la nueva VM. Debe seguir la nomenclatura corporativa y estar en minúsculas.
    environment = "uat"                         ## Ambiente destino: solo usar dev, uat o prd.
    os_profile  = "win2022"                     ## Perfil de sistema operativo: rocky9, ubuntu2404 o win2022.
    application = "cwrv"                        ## Label obligatorio: código de aplicación de IS.
    ticket      = "sr-12341"                    ## Label obligatorio: ticket de Fresh Service asociado a la creación.
    boot_disk_size_gb = 50                      ## Tamaño del disco booteable en GB.
    network_ip        = "10.43.152.121"         ## IP fija de la VM. Usar:
                                                ## dev = 10.43.150.X
                                                ## uat = 10.43.152.X
                                                ## prd = 10.43.154.X

    labels = {                                  ## Labels adicionales opcionales.
      owner = "infra"                           ## Ejemplo: owner, area, squad, costcenter, backup, etc.
    }
  }
}
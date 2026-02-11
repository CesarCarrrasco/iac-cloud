vms = {
  gccelxwsd15 = {
    project_id    = "is-development-389114"
    zone          = "us-east1-b"
    instance_name = "gccelxwsd15"

    boot_image        = "projects/rocky-linux-cloud/global/images/rocky-linux-9-optimized-gcp-v20260115"
    boot_disk_size_gb = 50
    machine_type      = "e2-medium"

    network_ip           = "10.43.150.22"
    subnetwork_self_link = "projects/shared-vpc-383515/regions/us-east1/subnetworks/is-snet-dev-core-is-vpc-desarrollo-shared-vpc"

    runtime_sa_email = "844194900662-compute@developer.gserviceaccount.com"

    environment = "DEV"
    application = "WEBSERVIS"
    ticket      = "SR-12341"
  }
}
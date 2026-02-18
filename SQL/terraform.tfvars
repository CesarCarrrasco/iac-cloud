impersonate_service_account = "REEMPLAZA_SA@REEMPLAZA_PROY.iam.gserviceaccount.com"
billing_project             = "iter-data-storage-mlops-is-com"

region = "us-east1"

sql_project_id       = "iter-data-storage-mlops-is-com"
sql_instance_name    = "gccspsp50-mlflow-prd"
sql_database_version = "POSTGRES_16"
sql_edition          = "ENTERPRISE"
sql_tier             = "db-f1-micro"
sql_storage_gb       = 10
sql_db_tz            = "America/Lima"
availability_type    = "ZONAL"

allowed_psc_projects = ["shared-vpc-383515", "iter-data-storage-mlops-is-com"]

consumer_project_id        = "shared-vpc-383515"
consumer_vpc               = "is-sec-prd-vpc1"
consumer_subnet            = "is-snet-prd-datos-is-vpc-prd-shared-vpc"
psc_ip_name                = "gccspsp50-mlflow-prd-csql-prd"
psc_ip                     = "10.43.174.101"
psc_forwarding_rule_name   = "gccspsp50-mlflow-prd-net-csql-prd"
psc_allow_global_access    = true

# db_names = ["bdlaf"]

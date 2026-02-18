#impersonate_service_account = "REEMPLAZA_SA@REEMPLAZA_PROY.iam.gserviceaccount.com"
billing_project = "is-development-389114"

region = "us-east1"

sql_project_id       = "is-development-389114"
sql_instance_name    = "gccspsp00-test"
sql_database_version = "POSTGRES_16" # Consider making this a variable too if it changes per environment
sql_tier             = "db-f1-micro"
sql_storage_gb       = 10
sql_db_tz            = "America/Lima"
availability_type    = "ZONAL"

allowed_psc_projects = ["shared-vpc-383515", "is-development-389114"]

consumer_project_id      = "shared-vpc-383515"
consumer_vpc             = "is-vpc-desarrollo"
consumer_subnet          = "is-snet-dev-core-is-vpc-desarrollo-shared-vpc"
psc_ip_name              = "gccspsp00-test-csql-prd"
psc_ip                   = "10.43.150.119"
psc_forwarding_rule_name = "gccspsp00-test-net-csql-prd"
psc_allow_global_access  = true

# db_names = ["bdlaf"]

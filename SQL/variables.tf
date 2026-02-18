variable "impersonate_service_account" {
  type        = string
  description = "Service Account a impersonar (ej: is-sa-tf-infra@PROJ.iam.gserviceaccount.com)"
}

variable "billing_project" {
  type        = string
  description = "Proyecto para cuota/billing cuando usas impersonación (opcional pero recomendado)"
  default     = null
}

variable "region" {
  type    = string
  default = "us-east1"
}

# ========= Productor (Cloud SQL) =========
variable "sql_project_id" {
  type    = string
  default = "iter-data-storage-mlops-is-com"
}

variable "sql_instance_name" {
  type    = string
  default = "gccspsp50-mlflow-prd"
}

variable "sql_database_version" {
  type    = string
  default = "POSTGRES_16"
}

variable "sql_edition" {
  type        = string
  description = "ENTERPRISE o ENTERPRISE_PLUS"
  default     = "ENTERPRISE"
}

variable "sql_tier" {
  type    = string
  default = "db-f1-micro"
}

variable "sql_storage_gb" {
  type    = number
  default = 10
}

variable "sql_storage_type" {
  type        = string
  description = "PD_SSD o PD_HDD"
  default     = "PD_SSD"
}

variable "sql_db_tz" {
  type    = string
  default = "America/Lima"
}

variable "availability_type" {
  type        = string
  description = "ZONAL o REGIONAL"
  default     = "ZONAL"
}

variable "allowed_psc_projects" {
  type        = list(string)
  description = "Proyectos autorizados a crear endpoints PSC hacia esta instancia"
  default     = ["shared-vpc-383515", "iter-data-storage-mlops-is-com"]
}

variable "labels" {
  type        = map(string)
  description = "Labels a aplicar a la instancia"
  default = {
    environment = "prd"
    application = "mlflow-prd"
    resource    = "sql"
  }
}

variable "deletion_protection" {
  type    = bool
  default = true
}

# ========= Consumidor (PSC endpoint) =========
variable "consumer_project_id" {
  type    = string
  default = "shared-vpc-383515"
}

variable "consumer_vpc" {
  type    = string
  default = "is-sec-prd-vpc1"
}

variable "consumer_subnet" {
  type    = string
  default = "is-snet-prd-datos-is-vpc-prd-shared-vpc"
}

variable "psc_ip_name" {
  type    = string
  default = "gccspsp50-mlflow-prd-csql-prd"
}

variable "psc_ip" {
  type        = string
  description = "IP fija del endpoint PSC. Si es null/vacío, se asigna automáticamente."
  default     = "10.43.174.101"
}

variable "psc_forwarding_rule_name" {
  type    = string
  default = "gccspsp50-mlflow-prd-net-csql-prd"
}

variable "psc_allow_global_access" {
  type    = bool
  default = true
}

# ========= Opcional: DBs =========
variable "db_names" {
  type        = set(string)
  description = "BDs a crear dentro de la instancia (opcional)"
  default     = []
}

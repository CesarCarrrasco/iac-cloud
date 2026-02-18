locals {
  # Tu script metía la IP en labels con puntos reemplazados. Si no hay IP fija, ponemos "auto".
  psc_ip_label = (
    var.psc_ip != null && trim(var.psc_ip) != ""
    ? replace(var.psc_ip, ".", "-")
    : "auto"
  )
}

provider "google" {
  project                     = var.sql_project_id
  region                      = var.region
  impersonate_service_account  = var.impersonate_service_account

  # Recomendado cuando impersonas para evitar errores de cuota en algunos APIs:
  user_project_override = var.billing_project != null
  billing_project       = var.billing_project
}

provider "google" {
  alias                       = "consumer"
  project                     = var.consumer_project_id
  region                      = var.region
  impersonate_service_account  = var.impersonate_service_account

  user_project_override = var.billing_project != null
  billing_project       = var.billing_project
}

# (Opcional) habilitar APIs (si ya están, no molesta; si no tienes permisos org, comenta)
resource "google_project_service" "sql_apis" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
  ])
  project            = var.sql_project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_project_service" "consumer_apis" {
  provider = google.consumer
  for_each = toset([
    "compute.googleapis.com",
  ])
  project            = var.consumer_project_id
  service            = each.value
  disable_on_destroy = false
}

# =======================
# 1) Cloud SQL (Productor) con PSC
# =======================
resource "google_sql_database_instance" "psc" {
  name             = var.sql_instance_name
  project          = var.sql_project_id
  region           = var.region
  database_version = var.sql_database_version
  edition          = var.sql_edition

  deletion_protection = var.deletion_protection

  settings {
    tier              = var.sql_tier
    availability_type = var.availability_type

    disk_size = var.sql_storage_gb
    disk_type = var.sql_storage_type

    # timezone=${SQL_DB_TZ}
    database_flags {
      name  = "timezone"
      value = var.sql_db_tz
    }

    user_labels = merge(var.labels, {
      ip = local.psc_ip_label
    })

    ip_configuration {
      ipv4_enabled = false

      # PSC habilitado + allow list de proyectos consumidores
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = var.allowed_psc_projects
      }
    }
  }

  depends_on = [
    google_project_service.sql_apis
  ]
}

# =======================
# 2) Referencias a VPC/Subnet existentes (Consumidor)
# =======================
data "google_compute_network" "consumer_vpc" {
  provider = google.consumer
  name     = var.consumer_vpc
  project  = var.consumer_project_id
}

data "google_compute_subnetwork" "consumer_subnet" {
  provider = google.consumer
  name     = var.consumer_subnet
  project  = var.consumer_project_id
  region   = var.region
}

# =======================
# 3) IP interna reservada para PSC endpoint
# =======================
resource "google_compute_address" "psc_ip" {
  provider     = google.consumer
  name         = var.psc_ip_name
  project      = var.consumer_project_id
  region       = var.region
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.consumer_subnet.self_link

  # Si var.psc_ip es null o "", se omite y GCP asigna una IP automáticamente
  address = (var.psc_ip != null && trim(var.psc_ip) != "") ? var.psc_ip : null

  depends_on = [
    google_project_service.consumer_apis
  ]
}

# =======================
# 4) Endpoint PSC (Forwarding Rule)
#    Nota: load_balancing_scheme debe ser "" para PSC con service attachment.
# =======================
resource "google_compute_forwarding_rule" "psc_endpoint" {
  provider = google.consumer

  name                  = var.psc_forwarding_rule_name
  project               = var.consumer_project_id
  region                = var.region
  network               = data.google_compute_network.consumer_vpc.self_link
  ip_address            = google_compute_address.psc_ip.self_link
  load_balancing_scheme = ""

  # Cloud SQL expone el service attachment como atributo computado:
  target = google_sql_database_instance.psc.psc_service_attachment_link

  allow_psc_global_access = var.psc_allow_global_access
}

# =======================
# 5) (Opcional) Crear DBs
# =======================
resource "google_sql_database" "dbs" {
  for_each = var.db_names

  name     = each.key
  project  = var.sql_project_id
  instance = google_sql_database_instance.psc.name

  charset   = "UTF8"
  collation = "en_US.UTF8"
}

# =======================
# Outputs
# =======================
output "cloudsql_instance" {
  value = google_sql_database_instance.psc.name
}

output "psc_service_attachment" {
  value = google_sql_database_instance.psc.psc_service_attachment_link
}

output "psc_endpoint_ip" {
  value = google_compute_address.psc_ip.address
}

output "psc_forwarding_rule" {
  value = google_compute_forwarding_rule.psc_endpoint.name
}
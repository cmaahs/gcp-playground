# ------------------------------------------------------------------------------
# Common tags to be assigned to resources
# ------------------------------------------------------------------------------

locals {
  common_tags = {
    Purpose     = var.labels_purpose
    Environment = var.environment
    Owner       = var.labels_owner
  }
}

# ------------------------------------------------------------------------------
# VPC Setup
# ------------------------------------------------------------------------------
module "network" {
  depends_on = [google_project_service.compute]
  source     = "terraform-google-modules/network/google"
  version    = "v3.5.0"

  project_id   = var.project_id
  network_name = "${var.environment}-${var.region}-network"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name      = "subnet-01-public"
      subnet_ip        = var.network_subnet_1_public
      subnet_region    = var.region
      subnet_flow_logs = "true"
      description      = "This subnet should be used by services that require public access"
    },
    {
      subnet_name           = "subnet-01-private"
      subnet_ip             = var.network_subnet_1_private
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet should be used by services that require private access"
    },
    {
      subnet_name           = "subnet-k8s-nodes-private"
      subnet_ip             = var.gke_subnet_k8s-nodes-private
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet is used by the kubernetes cluster create for the environment"
    },
  ]

  secondary_ranges = {
    "subnet-k8s-nodes-private" = [
      {
        range_name    = "subnet-k8s-pods-private"
        ip_cidr_range = var.gke_subnet_k8s-pods-private
      },
      {
        range_name    = "subnet-k8s-services-private"
        ip_cidr_range = var.gke_subnet_k8s-services-private
      },
    ]
  }
}

resource "google_compute_global_address" "private_ip_alloc" {
  depends_on    = [module.network]
  name          = "internal-service-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.network_private_service_ip
  prefix_length = var.network_private_service_ip_length
  network       = "${var.environment}-${var.region}-network"
}

resource "google_service_networking_connection" "foobar" {
  depends_on              = [google_compute_global_address.private_ip_alloc]
  network                 = "${var.environment}-${var.region}-network"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}


# ------------------------------------------------------------------------------
# GKE Setup - this is optional
# ------------------------------------------------------------------------------
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = var.gke_create ? "https://${module.gke[0].endpoint}" : ""
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = var.gke_create ? base64decode(module.gke[0].ca_certificate) : ""
}

module "gke" {
  depends_on = [google_project_service.k8s]
  count      = var.gke_create ? 1 : 0

  source                    = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                   = "v17.1.0"
  project_id                = var.project_id
  name                      = "${var.environment}-private-cluster"
  region                    = var.region
  zones                     = var.gke_node_zones
  network                   = "${var.environment}-${var.region}-network"
  subnetwork                = "subnet-k8s-nodes-private"
  ip_range_pods             = "subnet-k8s-pods-private"
  ip_range_services         = "subnet-k8s-services-private"
  network_policy            = var.gke_network_policy_enabled
  enable_private_endpoint   = var.gke_enable_private_endpoint
  enable_private_nodes      = var.gke_enable_private_nodes
  master_ipv4_cidr_block    = var.gke_master_ipv4_cidr_block
  remove_default_node_pool  = var.gke_remove_default_node_pool
  kubernetes_version        = var.gke_version
  release_channel           = var.gke_release_channel
  default_max_pods_per_node = var.gke_node_pool_max_pods_per_node

  node_pools = [
    {
      name               = "pool-01"
      machine_type       = var.gke_pool1_machine_type
      node_count         = var.gke_pool1_node_count
      initial_node_count = 1
      min_count          = var.gke_pool1_min_count
      max_count          = var.gke_pool1_max_count
      disk_size_gb       = var.gke_pool1_disk_size
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      max_pods_per_node  = var.gke_pool1_max_pods_per_node
    },
    {
      name               = "pool-02"
      machine_type       = var.gke_pool2_machine_type
      node_count         = var.gke_pool2_node_count
      initial_node_count = 0
      min_count          = var.gke_pool2_min_count
      max_count          = var.gke_pool2_max_count
      disk_size_gb       = var.gke_pool2_disk_size
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      max_pods_per_node  = var.gke_pool2_max_pods_per_node
    },
    
  ]

  node_pools_labels = {
    all = local.common_tags
  }
}

# ------------------------------------------------------------------------------
# Configure Cloud NAT to allow machines without External IPs to access the internet
# ------------------------------------------------------------------------------

resource "google_compute_router" "router" {
  depends_on = [google_project_service.compute]
  name       = "${var.environment}-${var.region}-router"
  region     = var.region
  network    = "${var.environment}-${var.region}-network"

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-${var.region}-router-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# ------------------------------------------------------------------------------
# Enables the cloudresourcemanager.googleapis.com API in the project
# ------------------------------------------------------------------------------
resource "google_project_service" "enable_cloud_resource_manager_api" {
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# ------------------------------------------------------------------------------
# Enables the secretmanager.googleapis.com API in the project
# ------------------------------------------------------------------------------
resource "google_project_service" "secret_manager" {
  depends_on = [google_project_service.enable_cloud_resource_manager_api]
  service    = "secretmanager.googleapis.com"
}

# ------------------------------------------------------------------------------
# Enables the compute.googleapis.com API in the project
# ------------------------------------------------------------------------------
resource "google_project_service" "compute" {
  depends_on                 = [google_project_service.enable_cloud_resource_manager_api]
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# ------------------------------------------------------------------------------
# Enables the container.googleapis.com API in the project
# ------------------------------------------------------------------------------
resource "google_project_service" "k8s" {
  depends_on                 = [google_project_service.enable_cloud_resource_manager_api]
  service                    = "container.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# ------------------------------------------------------------------------------
# Enables the servicenetworking.googleapis.com API in the project
# ------------------------------------------------------------------------------
resource "google_project_service" "service_project" {
  depends_on                 = [google_project_service.enable_cloud_resource_manager_api]
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}



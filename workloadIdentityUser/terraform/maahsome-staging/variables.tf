# ------------------------------------------------------------------------------
# Common variables - will vary by environment
# ------------------------------------------------------------------------------
variable "environment" {
  description = "The environment.  Either staging or prod"
  type        = string
}

variable "region" {
  description = "The region the resources should be created in"
  type        = string
  default     = "us-east4"
}

variable "project_id" {
  description = "The gcp project id where the resources will be created"
  type        = string
}

variable "labels_owner" {
  description = "The department that is the owner of this resource"
  type        = string
  default     = "platform-apps"
}

variable "labels_purpose" {
  description = "The purpose of this.  Could be development / testing / production"
  type        = string
  default     = "production"
}

# ------------------------------------------------------------------------------
# Variables for network - will vary by environment
# ------------------------------------------------------------------------------
variable "network_subnet_1_public" {
  description = "The VPC subnet for public ip addresses"
  type        = string
}

variable "network_subnet_1_private" {
  description = "The VPC subnet for private ip addresses"
  type        = string
}

variable "network_private_service_ip" {
  description = "The beginning of the address range for private services"
  type        = string
}

variable "network_private_service_ip_length" {
  description = "The prefix length of the IP range"
  type        = number
  default     = 19

}

# ------------------------------------------------------------------------------
# Variables for gke
# ------------------------------------------------------------------------------
variable "gke_create" {
  description = "Indicates if a gke cluster should be created"
  type        = bool
  default     = true
}

variable "gke_network_policy_enabled" {
  description = "Are network policies enabled.  This allows for multi-tenancy by defining a tenant-per-namespace model."
  type        = bool
  default     = true
}

variable "gke_master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  type        = string
}

variable "gke_subnet_k8s-nodes-private" {
  description = "The subnet used for the k8s nodes"
  type        = string
}

variable "gke_subnet_k8s-pods-private" {
  description = "The subnet used for the k8s pods"
  type        = string
}

variable "gke_subnet_k8s-services-private" {
  description = "The subnet used for the k8s services"
  type        = string
}

variable "gke_enable_private_endpoint" {
  description = "Whether the master's internal IP address is used as the cluster endpoint"
  type        = bool
  default     = false
}

variable "gke_enable_private_nodes" {
  description = "Whether nodes have internal IP addresses only"
  type        = bool
  default     = true
}

variable "gke_remove_default_node_pool" {
  description = "Remove default node pool while setting up the cluster"
  type        = bool
  default     = true
}

variable "gke_node_pool_max_pods_per_node" {
  description = "Default maximum number of pods per node for all pools"
  type        = number
  default     = 60
}

variable "gke_pool1_node_count" {
  description = "Number of nodes per instance group for the pool-01"
  type        = number
  default     = 1
}

variable "gke_pool1_min_count" {
  description = "Minimum number of nodes for the pool-01"
  type        = number
  default     = 1
}

variable "gke_pool1_max_count" {
  description = "Maximum number of nodes for the pool-01"
  type        = number
  default     = 100
}

variable "gke_pool1_max_pods_per_node" {
  description = "Maximum number of pods per node for the pool-01"
  type        = number
  default     = 60
}

variable "gke_pool2_node_count" {
  description = "Number of nodes per instance group for the pool-02"
  type        = number
  default     = 1
}

variable "gke_pool2_min_count" {
  description = "Minimum number of nodes for the pool-02"
  type        = number
  default     = 0
}

variable "gke_pool2_max_count" {
  description = "Maximum number of nodes for the pool-02"
  type        = number
  default     = 10
}

variable "gke_pool2_max_pods_per_node" {
  description = "Maximum number of pods per node for the pool-02"
  type        = number
  default     = 60
}

variable "gke_node_zones" {
  description = "List of zones for the gke project"
  type        = list(string)
  default     = ["us-east4-a"]
}

variable "gke_release_channel" {
  description = "The release channel of this cluster.  Valid values UNSPECIFIED, RAPID, REGULAR and STABLE"
  type        = string
  default     = "STABLE"
}

variable "gke_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "latest"
}

variable "gke_pool1_machine_type" {
  description = "The machine type for the pool-01"
  type        = string
  default     = "e2-medium"
}

variable "gke_pool1_disk_type" {
  description = "The disk type for the pool-01"
  type        = string
  default     = "pd-standard"
}

variable "gke_pool1_disk_size" {
  description = "The disk size for the pool-01"
  type        = number
  default     = 100
}

variable "gke_pool1_image_type" {
  description = "The image type for the pool-01"
  type        = string
  default     = "COS"
}

variable "gke_pool2_machine_type" {
  description = "The machine type for the pool-02"
  type        = string
  default     = "e2-highmem-16"
}

variable "gke_pool2_disk_type" {
  description = "The disk type for the pool-02"
  type        = string
  default     = "pd-standard"
}

variable "gke_pool2_disk_size" {
  description = "The disk size for the pool-02"
  type        = number
  default     = 200
}

variable "gke_pool2_image_type" {
  description = "The image type for the pool-02"
  type        = string
  default     = "COS"
}

# ------------------------------------------------------------------------------
# Variables for logging
# ------------------------------------------------------------------------------
variable "log_filter" {
  description = "Filter for the gcp to splunk"
  type        = string
  default     = "logName = /logs/cloudaudit.googleapis.com OR resource.type = gce_backend_service OR resource.type = audited_resource  OR resource.type = gce_route OR resource.type = gce_subnetwork"
}

variable "credentials_file" {
    type = string
}


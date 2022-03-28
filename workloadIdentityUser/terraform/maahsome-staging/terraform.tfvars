environment    = "staging"
project_id     = "maahsome-staging"
labels_purpose = "staging"

network_subnet_1_public = "10.13.0.0/19"
network_subnet_1_private = "10.13.32.0/19"
network_private_service_ip = "10.13.160.0"
network_private_service_ip_length = 19

gke_master_ipv4_cidr_block = "10.0.0.0/28"

gke_subnet_k8s-nodes-private = "10.13.64.0/19"
gke_subnet_k8s-pods-private = "10.13.96.0/19"
gke_subnet_k8s-services-private = "10.13.128.0/19"

gke_node_pool_max_pods_per_node = 8
gke_pool1_max_count = 8
gke_pool1_max_pods_per_node = 8
gke_pool2_max_count = 8

credentials_file = "/Users/cmaahs/.config/gcloud/legacy_credentials/maahsome@gmail.com/adc.json"

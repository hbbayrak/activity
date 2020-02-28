# Configure k8s cluster on digital ocean with terraform
resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.cluster_region
  version = var.kubernetes_version

  # Node pool configuration. Allows for the use of variable to
  # make the whole configuration reusable. Sets autoscalling to
  # true to cater for vertical node autoscaling, If pods exhaust
  # available resources in the minimum machine node
  node_pool {
    name       = "${var.cluster_name}-pool"
    size       = var.node_type
    auto_scale = true
    min_nodes  = var.min_node_number
    max_nodes  = var.max_node_number
  }
}

terraform {
  required_version = ">= 0.12.0"
  # DigitalOcean uses the S3 spec. 
  backend "s3" {
    endpoint = "https://nyc3.digitaloceanspaces.com"
    region = "eu-west-1"
    # Deactivate a few checks as TF will attempt these against AWS
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
}

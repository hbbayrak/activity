variable "cluster_name"{
  description="cluster name"
}

variable "cluster_region" {
  description="region of the kubernetes cluster"
}

variable "kubernetes_version" {
  description="version of kubernetes to be used"
}

variable "node_type" {
  description="type of nodes used as worker nodes"
}
variable "max_node_number" {
  description="number of maximum nodes"
}

variable "min_node_number" {
  description="number of maximum nodes"
}
variable "digital_ocean_token" {
  description="digital ocean access token"
}

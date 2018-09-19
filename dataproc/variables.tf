variable "cluster_location" {
  description = "Please input the cluster location like europe-west2 "
}

variable "project" {
  description = "The Project name"
}

variable "master_num_instances" {
  description = "Specifies the number of master nodes to create"
  default     = 3
}

variable "worker_num_instances" {
  description = "Specifies the number of worker nodes to create"
  default     = 3
}

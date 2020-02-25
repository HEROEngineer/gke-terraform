variable "cluster_location" {
  description = "Please input the cluster location like europe-west2 "
}

variable "project" {
  description = "The Project name"
}

variable "master_num_instances" {
  description = "Specifies the number of master nodes to create - Defaulted to HA"
  default     = 3
}

variable "worker_num_instances" {
  description = "Specifies the number of worker nodes to create"
  /**
  default     = 2
  **/
}

variable "master_machine_type" {
  description = "Specifies the machine type of master nodes to create"
  default     = "n1-standard-1"
}

variable "worker_machine_type" {
  description = "Specifies the machine type of worker nodes to create"
  default     = "n1-standard-1"
}


variable "bucket_name_dp" {
  description = "Specifies the bucket name to be created"
}

variable "cluster_dp_name" {
  description = "Specifies the dataproc cluster name"
}
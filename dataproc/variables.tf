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

variable "dataprocbuckloc" {
  type = map
  default = {
    "asia-east1"      = "ASIA"
    "asia-east2"      = "ASIA"
    "asia-northeast1" = "ASIA"
    "asia-northeast2" = "ASIA"
    "asia-northeast3" = "ASIA"
    "asia-south1"     = "ASIA"
    "asia-southeast1" = "ASIA"
    "europe-north1"   = "EU"
    "europe-west1"    = "EU"
    "europe-west2"    = "EU"
    "europe-west3"    = "EU"
    "europe-west4"    = "EU"
    "europe-west5"    = "EU"
    "europe-west6"    = "EU"
    "us-central1"     = "US"
    "us-east1"        = "US"
    "us-east4"        = "US"
    "us-west1"        = "US"
    "us-west2"        = "US"
    "us-west3"        = "US"
  }
}

variable "bq_dataset" {
  description = "The BigQuery Dataset ID name"
}
variable "bq_dataset_name" {
  description = "The BigQuery Dataset Friendly name"
}
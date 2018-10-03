variable "cluster_name" {
  description = "Please input the GKE cluster name "
}

variable "cluster_location" {
  description = "Please input the cluster location like europe-west2 "
}

variable "node_count" {
  description = "Please enter the node count "
}

variable "master_auth_username" {
  description = "Please enter the master auth username "
}

variable "master_auth_password" {
  description = "Please enter the master auth password "
}

variable "cluster_label" {
  description = "Please enter the cluster label "
}

variable "cluster_tag" {
  description = "Please enter the cluster tag "
}

variable "project" {
  description = "The Project name"
}

variable "gcp_machine_type" {
  description = "The Machine type"
  default     = "n1-standard-2"
}

variable "helm_install_jenkins" {
  description = "Please input whether to install Jenkins by default- true or false"
}

variable "install_prometheus_grafana" {
  description = "Please input whether to install Prometheus Grafana  by default- true or false"
}

variable "patch_prom_graf_lbr_external" {
  description = "Please input whether to expose Grafana to LBR - true or false"
}

variable "install_ibm_mq" {
  description = "Please input whether to install IBM MQ 9.1  by default- true or false"
}

variable "patch_ibm_mq_lbr_external" {
  description = "Please input whether to expose IBM MQ 9.1 Web console and MQ Default listener to External loadbalancer - true or false"
}

variable "install_ros_kinetic" {
  description = "Install ros-kinetic master, listener and talker services - true or false"
  default     = "false"
}

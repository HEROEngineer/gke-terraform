variable "cluster_name" {
  description = "Please input the GKE cluster name "
}

variable "cluster_location" {
  description = "Please input the cluster location like europe-west2 "
}

variable "node_count" {
  description = "Please enter the master node count - if this is 1, then there would be three nodes "
}

variable "master_auth_username" {
  description = "Please enter the master auth username "
}

variable "master_auth_password" {
  description = "Please enter the master auth password "
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
  default = "false"
}

variable "install_prometheus_grafana" {
  description = "Please input whether to install Prometheus Grafana  by default- true or false"
    default = "true"
}

variable "patch_prom_graf_lbr_external" {
  description = "Please input whether to expose Grafana to LBR - true or false"
    default = "true"
}

variable "install_ibm_mq" {
  description = "Please input whether to install IBM MQ 9.1  by default- true or false"
    default = "false"
}

variable "patch_ibm_mq_lbr_external" {
  description = "Please input whether to expose IBM MQ 9.1 Web console and MQ Default listener to External loadbalancer - true or false"
    default = "false"
}

variable "install_ros_kinetic" {
  description = "Install ros-kinetic master, listener and talker services - true or false"
  default     = "false"
}

variable "install_suitecrm" {
  description = "Install SuiteCRM with MariaDB - true or false"
    default = "false"
}

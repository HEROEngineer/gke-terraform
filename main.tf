data "google_container_engine_versions" "gce_version_zone" {
  zone = "${var.cluster_location}-a"
}

resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${var.cluster_location}-a"
  initial_node_count = "${var.node_count}"
  min_master_version = "${data.google_container_engine_versions.gce_version_zone.latest_node_version}"
  node_version       = "${data.google_container_engine_versions.gce_version_zone.latest_node_version}"

  additional_zones = [
    "${var.cluster_location}-b",
    "${var.cluster_location}-c",
  ]

  master_auth {
    username = "${var.master_auth_username}"
    password = "${var.master_auth_password}"
  }

  node_config {
    machine_type = "${var.gcp_machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/projecthosting",
    ]

    labels {
      foo = "${var.cluster_label}"
    }

    tags = ["${var.cluster_tag}"]
  }
}

resource "null_resource" "provision" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.cluster_location}-a --project ${var.project}"
  }

  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value account)"
  }

  provisioner "local-exec" {
    command = "kubectl create serviceaccount -n kube-system tiller && kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller"
  }

  provisioner "local-exec" {
    command = "curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh"
  }

  provisioner "local-exec" {
    command = "chmod 700 get_helm.sh"
  }

  provisioner "local-exec" {
    command = "./get_helm.sh"
  }

  provisioner "local-exec" {
    command = "helm init --service-account tiller --upgrade"
  }

  provisioner "local-exec" {
    command = <<EOF
            sleep 30
      EOF
  }

  provisioner "local-exec" {
    command = <<EOF
                if [ "${var.helm_install_jenkins}" = "true" ]; then
                    helm install -n ${var.cluster_name} stable/jenkins --set serviceAccountName=${var.cluster_name} -f jenkins-values.yaml --version 0.16.18
                else
                    echo ${var.helm_install_jenkins}
                fi
        EOF

    timeouts {
      create = "20m"
      delete = "20m"
    }
  }

  provisioner "local-exec" {
    command = "helm repo add gitlab https://charts.gitlab.io/ && helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/ && helm repo add bitnami https://charts.bitnami.com/bitnami"
  }

  provisioner "local-exec" {
    command = "helm repo update"
  }

  provisioner "local-exec" {
    command = <<EOF
              if [ "${var.install_prometheus_grafana}" = "true" ]; then
                  git clone https://github.com/coreos/prometheus-operator.git && cd prometheus-operator && kubectl apply -f bundle.yaml && mkdir -p helm/kube-prometheus/charts && helm package -d helm/kube-prometheus/charts helm/alertmanager helm/grafana helm/prometheus  helm/exporter-kube-dns helm/exporter-kube-scheduler helm/exporter-kubelets helm/exporter-node helm/exporter-kube-controller-manager helm/exporter-kube-etcd helm/exporter-kube-state helm/exporter-coredns helm/exporter-kubernetes
              else
                  echo ${var.install_prometheus_grafana}
              fi
        EOF
  }

  provisioner "local-exec" {
    command = <<EOF
              if [ "${var.install_prometheus_grafana}" = "true" ]; then
                  sleep 30
              else
                  echo ${var.install_prometheus_grafana}
              fi
        EOF
  }

  provisioner "local-exec" {
    command = <<EOF
                if [ "${var.install_prometheus_grafana}" = "true" ]; then
                    cd prometheus-operator && helm install helm/kube-prometheus --name kube-prometheus --namespace monitoring
                else
                    echo ${var.install_prometheus_grafana}
                fi
          EOF
  }

  provisioner "local-exec" {
    command = <<EOF
              if [ "${var.patch_prom_graf_lbr_external}" = "true" ]; then
                  kubectl patch svc kube-prometheus-grafana -p '{"spec":{"type":"LoadBalancer"}}' --namespace monitoring
              else
                  echo ${var.patch_prom_graf_lbr_external}
              fi
        EOF
  }

  provisioner "local-exec" {
    command = <<EOF
              if [ "${var.install_ros_kinetic}" = "true" ]; then
                  kubectl create namespace ros-kinetic && kubectl create -f ros-master.yaml --namespace ros-kinetic && kubectl create -f ros-headless-listener.yaml --namespace ros-kinetic && kubectl create -f ros-talker-service.yaml --namespace ros-kinetic 
              else
                  echo ${var.install_ros_kinetic}
              fi
        EOF
  }

  provisioner "local-exec" {
    command = <<EOF
                if [ "${var.install_ibm_mq}" = "true" ]; then
                    kubectl create namespace ibm && helm install --name mqserver ibm-charts/ibm-mqadvanced-server-dev --set license=accept --namespace ibm
                else
                    echo ${var.install_ibm_mq}
                fi
          EOF
  }

  provisioner "local-exec" {
    command = <<EOF
              if [ "${var.patch_ibm_mq_lbr_external}" = "true" ]; then
                  kubectl patch svc mqserver-ibm-mq -p '{"spec":{"type":"LoadBalancer"}}' --namespace ibm
              else
                  echo ${var.patch_ibm_mq_lbr_external}
              fi
        EOF
  }
  provisioner "local-exec" {
    command = <<EOF
                if [ "${var.install_suitecrm}" = "true" ]; then
                    kubectl create namespace sugarcrm && helm install --name sugarcrm-dev --set allowEmptyPassword=false,mariadb.rootUser.password=secretpassword,mariadb.db.password=secretpassword stable/suitecrm --namespace sugarcrm && sleep 60 && export APP_HOST=$(kubectl get svc --namespace sugarcrm sugarcrm-dev-suitecrm --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}") && export APP_PASSWORD=$(kubectl get secret --namespace sugarcrm sugarcrm-dev-suitecrm -o jsonpath="{.data.suitecrm-password}" | base64 --decode) && export APP_DATABASE_PASSWORD=$(kubectl get secret --namespace sugarcrm sugarcrm-dev-mariadb -o jsonpath="{.data.mariadb-password}" | base64 --decode) && helm upgrade sugarcrm-dev stable/suitecrm --set suitecrmHost=$APP_HOST,suitecrmPassword=$APP_PASSWORD,mariadb.db.password=$APP_DATABASE_PASSWORD
                else
                    echo ${var.install_suitecrm}
                fi
          EOF
  }
  depends_on = ["google_container_cluster.primary"]
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

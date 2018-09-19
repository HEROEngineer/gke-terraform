resource "google_storage_bucket" "pocstagingbuck" {
  name          = "dataproc-poc-staging-bucket"
  location      = "US"
  force_destroy = "true"
}

resource "google_dataproc_cluster" "poccluster" {
  name   = "poccluster"
  region = "${var.cluster_location}"

  labels {
    foo = "bar"
  }

  cluster_config {
    staging_bucket = "${google_storage_bucket.pocstagingbuck.name}"

    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"

      disk_config {
        boot_disk_type    = "pd-ssd"
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-2"

      disk_config {
        boot_disk_size_gb = 30
        num_local_ssds    = 1
      }
    }

    preemptible_worker_config {
      num_instances = 0
    }

    # Override or set some custom properties
    software_config {
      image_version = "1.3.8-deb9"

      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }

    gce_cluster_config {
      #network = "${google_compute_network.dataproc_network.name}"
      tags = ["foo", "bar"]
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
      timeout_sec = 500
    }
  }

  depends_on = ["google_storage_bucket.pocstagingbuck"]
}

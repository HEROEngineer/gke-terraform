resource "google_storage_bucket" "pocstagingbuck" {
  name          = "dataproc-poc-staging-bucket"
  location      = "EU"
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
      machine_type  = "n1-standard-4"

      disk_config {
        boot_disk_type    = "pd-ssd"
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"

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
      network = "${google_compute_network.dataproc_network.name}"
      tags    = ["foo", "bar"]
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
      timeout_sec = 500
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/drill/drill.sh"
      timeout_sec = 500
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/jupyter2/jupyter2.sh"
      timeout_sec = 500
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/ganglia/ganglia.sh"
      timeout_sec = 500
    }
  }

  depends_on = ["google_storage_bucket.pocstagingbuck"]
}

# Submit an example spark job to a dataproc cluster
resource "google_dataproc_job" "spark" {
  region       = "${google_dataproc_cluster.poccluster.region}"
  force_delete = true

  placement {
    cluster_name = "${google_dataproc_cluster.poccluster.name}"
  }

  spark_config {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["1000"]

    properties = {
      "spark.logConf" = "true"
    }

    logging_config {
      driver_log_levels {
        "root" = "INFO"
      }
    }
  }
}

# Submit an example pyspark job to a dataproc cluster
resource "google_dataproc_job" "pyspark" {
  region       = "${google_dataproc_cluster.poccluster.region}"
  force_delete = true

  placement {
    cluster_name = "${google_dataproc_cluster.poccluster.name}"
  }

  pyspark_config {
    main_python_file_uri = "gs://dataproc-examples-2f10d78d114f6aaec76462e3c310f31f/src/pyspark/hello-world/hello-world.py"

    properties = {
      "spark.logConf" = "true"
    }
  }
}

# Check out current state of the jobs
output "spark_status" {
  value = "${google_dataproc_job.spark.status.0.state}"
}

output "pyspark_status" {
  value = "${google_dataproc_job.pyspark.status.0.state}"
}

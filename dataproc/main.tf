resource "google_storage_bucket" "tstdataprocbuck" {
  name          = var.bucket_name_dp
  location      = lookup(var.dataprocbuckloc, var.cluster_location)
  force_destroy = "true"
}

resource "google_dataproc_cluster" "tstdataprocclus" {
  name   = var.cluster_dp_name
  region = var.cluster_location

  labels = {
    foo = "bar"
  }

  cluster_config {
    staging_bucket = google_storage_bucket.tstdataprocbuck.name

    master_config {
      num_instances    = var.master_num_instances
      machine_type     = var.master_machine_type
      min_cpu_platform = "Intel Skylake"

      disk_config {
        boot_disk_type    = "pd-ssd"
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances    = var.worker_num_instances
      machine_type     = var.worker_machine_type
      min_cpu_platform = "Intel Skylake"

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
      image_version = "1.4.21-debian9"

      override_properties = {
        "dataproc:dataproc.allow.zero.workers"        = "true"
        "dataproc:dataproc.conscrypt.provider.enable" = "false"
      }
    }

    gce_cluster_config {
      network = google_compute_network.dataproc_network.name
      tags    = ["foo", "bar"]
    }

    # You can define multiple initialization_action blocks
    initialization_action {
      script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
      timeout_sec = 500
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/ganglia/ganglia.sh"
      timeout_sec = 500
    }
    initialization_action {
      script      = "gs://dataproc-initialization-actions/docker/docker.sh"
      timeout_sec = 500
    }

    initialization_action {
      script      = "gs://dataproc-initialization-actions/livy/livy.sh"
      timeout_sec = 500
    }
    initialization_action {
      script      = "gs://dataproc-initialization-actions/kafka/kafka.sh"
      timeout_sec = 500
    }
    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.asp.name
    }
  }

  depends_on = [google_storage_bucket.tstdataprocbuck]

  timeouts {
    create = "30m"
    delete = "30m"
  }
}
resource "google_dataproc_autoscaling_policy" "asp" {
  policy_id = "dataproc-policy"
  location  = var.cluster_location

  worker_config {
    max_instances = 3
  }

  basic_algorithm {
    yarn_config {
      graceful_decommission_timeout = "30s"

      scale_up_factor   = 0.5
      scale_down_factor = 0.5
    }
  }
}
# Submit an example spark job to a dataproc cluster
resource "google_dataproc_job" "spark" {
  region       = google_dataproc_cluster.tstdataprocclus.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tstdataprocclus.name
  }

  spark_config {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["1000"]

    properties = {
      "spark.logConf" = "true"
    }

    logging_config {
      driver_log_levels = {
        "root" = "INFO"
      }
    }
  }
}

# Submit a hadoop job to the cluster
resource "google_dataproc_job" "hadoop" {
  region       = google_dataproc_cluster.tstdataprocclus.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tstdataprocclus.name
  }

  hadoop_config {
    main_jar_file_uri = "file:///usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar"

    args = [
      "wordcount",
      "file:///usr/lib/spark/NOTICE",
      "gs://${google_dataproc_cluster.tstdataprocclus.cluster_config.0.bucket}/hadoopjob_output",
    ]
  }
}

resource "google_dataproc_job" "sparksql" {
  region       = google_dataproc_cluster.tstdataprocclus.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tstdataprocclus.name
  }

  sparksql_config {
    query_list = [
      "DROP TABLE IF EXISTS dprocjob_test",
      "CREATE TABLE dprocjob_test(bar int)",
      "SELECT * FROM dprocjob_test WHERE bar > 2",
    ]
  }
}

# Submit a pig job to the cluster
resource "google_dataproc_job" "pig" {
  region       = google_dataproc_cluster.tstdataprocclus.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tstdataprocclus.name
  }

  pig_config {
    query_list = [
      "LNS = LOAD 'file:///usr/lib/pig/LICENSE.txt ' AS (line)",
      "WORDS = FOREACH LNS GENERATE FLATTEN(TOKENIZE(line)) AS word",
      "GROUPS = GROUP WORDS BY word",
      "WORD_COUNTS = FOREACH GROUPS GENERATE group, COUNT(WORDS)",
      "DUMP WORD_COUNTS",
    ]
  }
}

# Submit an example pyspark job to a dataproc cluster
resource "google_dataproc_job" "pyspark" {
  region       = google_dataproc_cluster.tstdataprocclus.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tstdataprocclus.name
  }

  pyspark_config {
    main_python_file_uri = "gs://dataproc-examples-2f10d78d114f6aaec76462e3c310f31f/src/pyspark/hello-world/hello-world.py"

    properties = {
      "spark.logConf" = "true"
    }
  }
}


resource "google_bigquery_dataset" "default" {
  dataset_id                  = var.bq_dataset
  friendly_name               = var.bq_dataset_name
  description                 = "This is a test description"
  location                    = lookup(var.dataprocbuckloc, var.cluster_location)
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "bar"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = file("schema.json")
}

# Check out current state of the jobs
output "BigQuery_dataset_status" {
  value = google_bigquery_table.default.dataset_id
}
output "google_bucket_status" {
  value = google_storage_bucket.tstdataprocbuck.url
}

output "dataproc_cluster_status" {
  value = google_dataproc_cluster.tstdataprocclus.id
}
output "dataproc_master_status" {
  value = google_dataproc_cluster.tstdataprocclus.cluster_config.0.master_config.0.instance_names
}
output "dataproc_worker_status" {
  value = google_dataproc_cluster.tstdataprocclus.cluster_config.0.worker_config.0.instance_names
}
output "spark_status" {
  value = google_dataproc_job.spark.status.0.state
}

output "pyspark_status" {
  value = google_dataproc_job.pyspark.status.0.state
}

output "pig_status" {
  value = google_dataproc_job.pig.status.0.state
}

output "hadoopjob_status" {
  value = google_dataproc_job.hadoop.status.0.state
}

output "sparksql_status" {
  value = google_dataproc_job.sparksql.status.0.state
}

output "logs_directory_browser_url" {

  value       = join("", google_storage_bucket.tstdataprocbuck.*.url)
  description = "The base URL of the bucket, in the format gs://<bucket-name>"
}

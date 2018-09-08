provider "google" {
  credentials = "${file("credentials/google.json")}"
  project     = "maximal-furnace-202714"
  region      = "${var.cluster_location}-a"
}

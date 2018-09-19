resource "google_compute_network" "dataproc_network" {
  name                    = "${var.project}-dataproc"
  auto_create_subnetworks = true
}

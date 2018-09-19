resource "google_compute_network" "dataproc" {
  name                    = "${var.project}-dataproc"
  auto_create_subnetworks = true
}

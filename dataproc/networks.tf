resource "google_compute_network" "dataproc" {
  name                    = "${var.environment}-dataproc"
  auto_create_subnetworks = true
}

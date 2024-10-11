resource "google_compute_network" "vpc" {
  name                    = "${local.base_name}-vpc"
  auto_create_subnetworks = false
}

#tfsec:ignore:google-compute-enable-vpc-flow-logs Skipped as vpc flows logs are only needed for debugging issues.
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  #checkov:skip=CKV_GCP_26 Skipped as the VPC logs will be enabled only during the time of debugging of issue
  #checkov:skip=CKV_GCP_76 Skipped as Private google access is not enabled for IPV6
  name                     = "${local.base_name}-subnet"
  ip_cidr_range            = "10.0.0.0/16"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = "tf-test-secondary-range-update1"
    ip_cidr_range = "192.168.10.0/24"
  }
}

resource "google_compute_router" "router" {
  name    = "${local.base_name}-router"
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  network = google_compute_network.goldimgvpc.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${local.base_name}-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allowiap" {
  name    = "${local.base_name}-allow-ingress-from-iap"
  network = google_compute_network.goldimgvpc.name

  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "allowwinrm" {
  name    = "${local.base_name}-allow-winrm"
  network = google_compute_network.vpc.name

  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["5986"]
  }
}

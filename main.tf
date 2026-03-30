# main.tf — Configuration Infrastructure Cloudflare Tunnel

# ============================================
# 🌐 Réseau VPC Partagé
# ============================================

resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# ============================================
# 🔒 Pare-feu - SSH uniquement pour Ansible
# ============================================

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Autoriser le trafic interne entre VMs (tunnel -> web)
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["10.0.0.0/24", "10.1.0.0/24"]
  target_tags   = ["ssh-enabled"]
}

# Pas d'autres ports ouverts - tout le trafic web externe passe par cloudflared

# ============================================
# 🇪🇺 Region europe-west1
# ============================================

resource "google_compute_subnetwork" "subnet_eu" {
  name          = "subnet-europe-west1"
  ip_cidr_range = "10.0.0.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc.id
}

# VM Web Europe - Serveur nginx
resource "google_compute_instance" "vm_web_eu" {
  name         = "vm-web-europe"
  machine_type = var.machine_type
  zone         = "europe-west1-b"

  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image   = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size    = 20
      type    = "pd-standard"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet_eu.id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }
}

# VM Tunnel Europe - Cloudflared
resource "google_compute_instance" "vm_tunnel_eu" {
  name         = "vm-tunnel-europe"
  machine_type = var.machine_type
  zone         = "europe-west1-b"

  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image   = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size    = 20
      type    = "pd-standard"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet_eu.id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }
}

# ============================================
# 🇺🇸 Region us-central1
# ============================================

resource "google_compute_subnetwork" "subnet_us" {
  name          = "subnet-us-central1"
  ip_cidr_range = "10.1.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc.id
}

# VM Web US - Serveur nginx
resource "google_compute_instance" "vm_web_us" {
  name         = "vm-web-us"
  machine_type = var.machine_type
  zone         = "us-central1-a"

  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image   = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size    = 20
      type    = "pd-standard"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet_us.id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }
}

# VM Tunnel US - Cloudflared
resource "google_compute_instance" "vm_tunnel_us" {
  name         = "vm-tunnel-us"
  machine_type = var.machine_type
  zone         = "us-central1-a"

  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image   = "projects/${var.image_project}/global/images/family/${var.image_family}"
      size    = 20
      type    = "pd-standard"
    }
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet_us.id
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${var.ssh_public_key}"
  }
}
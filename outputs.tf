# ============================================
# 🇪🇺 Europe VMs
# ============================================

output "vm_web_eu_ip" {
  description = "IP de la VM Web Europe"
  value       = google_compute_instance.vm_web_eu.network_interface[0].access_config[0].nat_ip
}

output "vm_web_eu_name" {
  description = "Nom de la VM Web Europe"
  value       = google_compute_instance.vm_web_eu.name
}

output "vm_tunnel_eu_ip" {
  description = "IP de la VM Tunnel Europe"
  value       = google_compute_instance.vm_tunnel_eu.network_interface[0].access_config[0].nat_ip
}

output "vm_tunnel_eu_name" {
  description = "Nom de la VM Tunnel Europe"
  value       = google_compute_instance.vm_tunnel_eu.name
}

# ============================================
# 🇺🇸 US VMs
# ============================================

output "vm_web_us_ip" {
  description = "IP de la VM Web US"
  value       = google_compute_instance.vm_web_us.network_interface[0].access_config[0].nat_ip
}

output "vm_web_us_name" {
  description = "Nom de la VM Web US"
  value       = google_compute_instance.vm_web_us.name
}

output "vm_tunnel_us_ip" {
  description = "IP de la VM Tunnel US"
  value       = google_compute_instance.vm_tunnel_us.network_interface[0].access_config[0].nat_ip
}

output "vm_tunnel_us_name" {
  description = "Nom de la VM Tunnel US"
  value       = google_compute_instance.vm_tunnel_us.name
}
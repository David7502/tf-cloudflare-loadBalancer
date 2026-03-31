# cloudflare.tf — Tunnels, Load Balancer et DNS

# ============================================
# 🚇 Tunnels Cloudflare (remotely-managed)
# ============================================

resource "random_id" "tunnel_secret_eu" {
  byte_length = 32
}

resource "random_id" "tunnel_secret_us" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel_eu" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-tunnel-europe"
  secret     = random_id.tunnel_secret_eu.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel_us" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-tunnel-us"
  secret     = random_id.tunnel_secret_us.b64_std
}

# Configuration des tunnels (ingress rules)
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_eu_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel_eu.id

  config {
    ingress_rule {
      hostname = var.cloudflare_domain
      service  = "http://${google_compute_instance.vm_web_eu.network_interface[0].network_ip}:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_us_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel_us.id

  config {
    ingress_rule {
      hostname = var.cloudflare_domain
      service  = "http://${google_compute_instance.vm_web_us.network_interface[0].network_ip}:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

# ============================================
# ⚖️ Load Balancer Cloudflare
# ============================================

resource "cloudflare_load_balancer_pool" "pool_eu" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-pool-europe"

  origins = [{
    name    = "${var.prefix}-tunnel-europe"
    address = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel_eu.id}.cfargotunnel.com"
    enabled = true
  }]
}

resource "cloudflare_load_balancer_pool" "pool_us" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-pool-us"

  origins = [{
    name    = "${var.prefix}-tunnel-us"
    address = "${cloudflare_zero_trust_tunnel_cloudflared.tunnel_us.id}.cfargotunnel.com"
    enabled = true
  }]
}

resource "cloudflare_load_balancer" "lb" {
  zone_id        = var.cloudflare_zone_id
  name           = var.cloudflare_domain
  fallback_pool  = cloudflare_load_balancer_pool.pool_eu.id
  default_pools  = [
    cloudflare_load_balancer_pool.pool_eu.id,
    cloudflare_load_balancer_pool.pool_us.id
  ]
  proxied         = true
  steering_policy = "random"
}

# ============================================
# 📤 Outputs Cloudflare
# ============================================

output "tunnel_eu_token" {
  description = "Token du tunnel Europe pour cloudflared"
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel_eu.tunnel_token
  sensitive   = true
}

output "tunnel_us_token" {
  description = "Token du tunnel US pour cloudflared"
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel_us.tunnel_token
  sensitive   = true
}

output "tunnel_eu_id" {
  description = "ID du tunnel Europe"
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel_eu.id
}

output "tunnel_us_id" {
  description = "ID du tunnel US"
  value       = cloudflare_zero_trust_tunnel_cloudflared.tunnel_us.id
}

output "load_balancer_hostname" {
  description = "Hostname du load balancer"
  value       = cloudflare_load_balancer.lb.name
}

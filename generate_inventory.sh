#!/bin/bash
# Génère l'inventory Ansible depuis les outputs Terraform

set -e

# Récupérer les IPs depuis Terraform
VM_WEB_EU_IP=$(terraform output -raw vm_web_eu_ip)
VM_WEB_US_IP=$(terraform output -raw vm_web_us_ip)
VM_TUNNEL_EU_IP=$(terraform output -raw vm_tunnel_eu_ip)
VM_TUNNEL_US_IP=$(terraform output -raw vm_tunnel_us_ip)

# Récupérer les IPs internes des VMs web (pour la config cloudflared)
VM_WEB_EU_INTERNAL=$(terraform output -raw vm_web_eu_internal_ip)
VM_WEB_US_INTERNAL=$(terraform output -raw vm_web_us_internal_ip)

# Récupérer les tokens des tunnels Cloudflare
TUNNEL_EU_TOKEN=$(terraform output -raw tunnel_eu_token)
TUNNEL_US_TOKEN=$(terraform output -raw tunnel_us_token)

# Générer l'inventory
cat > ansible/inventory.ini << EOF
# ============================================
# 🌐 VMs Web (nginx)
# ============================================

[web]
lb-vm-web-europe ansible_host=${VM_WEB_EU_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 region=europe-west1
lb-vm-web-us ansible_host=${VM_WEB_US_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 region=us-central1

# ============================================
# ☁️ VMs Tunnel (cloudflared)
# ============================================

[tunnel]
lb-vm-tunnel-europe ansible_host=${VM_TUNNEL_EU_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 web_server_ip=${VM_WEB_EU_INTERNAL} tunnel_token=${TUNNEL_EU_TOKEN}
lb-vm-tunnel-us ansible_host=${VM_TUNNEL_US_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 web_server_ip=${VM_WEB_US_INTERNAL} tunnel_token=${TUNNEL_US_TOKEN}
EOF

echo "✅ Inventory généré: ansible/inventory.ini"

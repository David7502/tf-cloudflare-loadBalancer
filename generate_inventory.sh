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

# Générer l'inventory
cat > ansible/inventory.ini << EOF
# ============================================
# 🌐 VMs Web (nginx)
# ============================================

[web]
vm-web-europe ansible_host=${VM_WEB_EU_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 region=europe-west1
vm-web-us ansible_host=${VM_WEB_US_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 region=us-central1

# ============================================
# ☁️ VMs Tunnel (cloudflared)
# ============================================

[tunnel]
vm-tunnel-europe ansible_host=${VM_TUNNEL_EU_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 web_server_ip=${VM_WEB_EU_INTERNAL}
vm-tunnel-us ansible_host=${VM_TUNNEL_US_IP} ansible_user=david ansible_ssh_private_key_file=~/.ssh/id_ed25519 web_server_ip=${VM_WEB_US_INTERNAL}
EOF

echo "✅ Inventory généré: ansible/inventory.ini"

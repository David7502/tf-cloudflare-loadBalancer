#!/bin/bash
# Script de déploiement complet : Terraform + Ansible

set -e

echo "🚀 Déploiement de l'infrastructure..."

# 1. Terraform
echo "📦 Terraform apply..."
terraform apply -auto-approve

# 2. Générer l'inventory Ansible
echo "📝 Génération de l'inventory Ansible..."
./generate_inventory.sh

# 3. Attendre que les VMs soient prêtes (SSH disponible)
echo "⏳ Attente que les VMs soient accessibles (30s)..."
sleep 30

# 4. Lancer Ansible pour les VMs web
echo "🌐 Configuration des VMs web (nginx)..."
cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml

# 5. Lancer Ansible pour les VMs tunnel
echo "☁️ Configuration des VMs tunnel (cloudflared)..."
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook_tunnel.yml

echo ""
echo "✅ Déploiement terminé !"
echo ""
echo "📊 IPs des VMs :"
cd ..
terraform output

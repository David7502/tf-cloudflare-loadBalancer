# Cloudflare Tunnel Infrastructure

Déploiement de 4 VMs GCP avec Cloudflare Tunnels pour exposer des sites web sans ouvrir de ports.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloudflare                                │
│                     (Load Balancer)                              │
└─────────────────┬───────────────────────────┬───────────────────┘
                  │                           │
         ┌────────▼────────┐         ┌────────▼────────┐
         │  Tunnel Europe  │         │   Tunnel US     │
         │  (cloudflared)  │         │  (cloudflared)  │
         └────────┬────────┘         └────────┬────────┘
                  │                           │
         ┌────────▼────────┐         ┌────────▼────────┐
         │   VM Web EU     │         │   VM Web US     │
         │ "Hello From CF" │         │ "Hello From CF" │
         │ X-Region: eu    │         │ X-Region: us    │
         └─────────────────┘         └─────────────────┘
```

**4 VMs déployées :**
- **vm-web-europe** : nginx avec header `X-Region: europe-west1`
- **vm-tunnel-europe** : cloudflared connecté à vm-web-europe
- **vm-web-us** : nginx avec header `X-Region: us-central1`
- **vm-tunnel-us** : cloudflared connecté à vm-web-us

**Sécurité** : Aucun port ouvert dans le firewall GCP. Tout le trafic passe par les tunnels Cloudflare.

## 📋 Prérequis

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- Compte Google Cloud Platform (GCP)
- Compte Cloudflare avec 2 tunnels créés
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## 🔧 Installation

### 1. Configurer Terraform

```bash
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec votre project_id et ssh_public_key
```

### 2. Déployer l'infrastructure

```bash
terraform init
terraform apply
```

### 3. Configurer Ansible

Après `terraform apply`, récupérer les IPs :

```bash
terraform output
```

Mettre à jour `ansible/inventory.ini` avec les IPs.

Créer les fichiers de credentials pour les tunnels :

```bash
cp ansible/host_vars/vm-tunnel-europe.yml.example ansible/host_vars/vm-tunnel-europe.yml
cp ansible/host_vars/vm-tunnel-us.yml.example ansible/host_vars/vm-tunnel-us.yml
# Éditer avec vos credentials Cloudflare
```

### 4. Provisionner les VMs

```bash
cd ansible

# Installer nginx sur les VMs web
ansible-playbook -i inventory.ini playbook.yml

# Installer cloudflared sur les VMs tunnel
ansible-playbook -i inventory.ini playbook_tunnel.yml
```

## 📁 Structure

```
├── main.tf                 # 4 VMs + VPC (pas de firewall)
├── variables.tf            # Variables globales
├── outputs.tf              # IPs des VMs
├── provider.tf             # Provider GCP
└── ansible/
    ├── inventory.ini       # Inventaire des VMs
    ├── playbook.yml        # Playbook nginx (VMs web)
    ├── playbook_tunnel.yml # Playbook cloudflared (VMs tunnel)
    └── host_vars/          # Credentials par tunnel
```

## � Sécurité

- **Firewall GCP** : Aucune règle, tous les ports bloqués
- **Accès** : Uniquement via tunnels Cloudflare
- **Fichiers sensibles** : Ne pas commiter `*.tfvars`, `host_vars/*.yml`, `*.tfstate`

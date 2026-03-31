# Cloudflare Tunnel Infrastructure

Déploiement **100% automatisé** de 4 VMs GCP avec Cloudflare Tunnels, Load Balancer et DNS.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloudflare                                │
│              (Load Balancer + DNS + Tunnels)                     │
│                    ↑ créés par Terraform                         │
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

**Ressources créées automatiquement :**

**GCP :**
- 4 VMs (2 web + 2 tunnel) dans 2 régions
- VPC + Subnets + Firewall (SSH + interne uniquement)

**Cloudflare :**
- 2 Tunnels (Europe + US)
- Load Balancer avec geo-steering
- Records DNS

## 📋 Prérequis

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Compte Google Cloud Platform (GCP)
- Compte Cloudflare avec :
  - Un domaine configuré
  - Un API Token avec permissions : `Zone:Read`, `Zone:Edit`, `DNS:Edit`, `Load Balancer:Edit`, `Cloudflare Tunnel:Edit`

## 🔧 Installation

### 1. Cloner le repository

```bash
git clone https://github.com/David7502/tf-cloudflare-loadBalancer.git
cd tf-cloudflare-loadBalancer
```

### 2. Configurer Terraform

```bash
cp terraform.tfvars.example terraform.tfvars
```

Éditer `terraform.tfvars` :

```hcl
# GCP
project_id     = "your-gcp-project-id"
ssh_username   = "david"
ssh_public_key = "ssh-ed25519 AAAA..."

# Cloudflare
cloudflare_api_token  = "your-api-token"
cloudflare_account_id = "your-account-id"
cloudflare_zone_id    = "your-zone-id"
cloudflare_domain     = "lb-demo.example.com"
```

> **Trouver vos IDs Cloudflare :**
> - Account ID : Dashboard → clic sur votre domaine → colonne droite
> - Zone ID : Dashboard → clic sur votre domaine → colonne droite
> - API Token : My Profile → API Tokens → Create Token

### 3. Déployer

```bash
terraform init
./deploy.sh
```

Le script déploie automatiquement :
1. **Terraform** : VMs GCP + Tunnels + Load Balancer + DNS Cloudflare
2. **Ansible** : nginx sur VMs web + cloudflared sur VMs tunnel

### 4. Tester

```bash
curl -I https://lb-demo.example.com
```

Vous devriez voir le header `X-Region` correspondant à votre localisation.

## 📁 Structure

```
├── main.tf                 # VMs GCP + VPC + Firewall
├── cloudflare.tf           # Tunnels + Load Balancer + DNS
├── variables.tf            # Variables GCP + Cloudflare
├── outputs.tf              # IPs des VMs
├── provider.tf             # Providers GCP + Cloudflare
├── deploy.sh               # Script de déploiement automatique
├── generate_inventory.sh   # Génère l'inventory Ansible
└── ansible/
    ├── inventory.ini       # Inventaire (généré automatiquement)
    ├── playbook.yml        # nginx (VMs web)
    └── playbook_tunnel.yml # cloudflared (VMs tunnel)
```

## 🔐 Sécurité

- **Firewall GCP** : SSH (22) + HTTP interne (80) uniquement
- **Accès web** : Uniquement via tunnels Cloudflare
- **Fichiers sensibles** : Ne pas commiter `*.tfvars`, `*.tfstate`

## 🗑️ Destruction

```bash
terraform destroy
```

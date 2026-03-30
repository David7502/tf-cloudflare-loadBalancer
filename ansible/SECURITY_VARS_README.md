# Variables Sensibles - Guide de Sécurité

## 🔒 Gestion des Variables Sensibles

Les variables Cloudflared contiennent des informations sensibles qui **NE DOIVENT PAS** être commitées sur Git.

## 📋 Configuration

### 1. Copier le template

```bash
cd ansible
cp vars.local.yml.example vars.local.yml
```

### 2. Remplir vos vraies valeurs

Éditez `vars.local.yml` avec vos informations réelles :

```yaml
# Variables pour Cloudflared
# CE FICHIER N'EST PAS COMMITE - IL CONTIENT VOS VALEURS SENSIBLES

# Pour VM1 (web)
cloudflared_tunnel_id: "votre-vrai-tunnel-id-vm1"
cloudflared_hostname: "scroll.dgcf.ovh"
cloudflared_credentials:
  AccountTag: "votre-vrai-account-tag"
  TunnelID: "votre-vrai-tunnel-id-vm1"
  TunnelSecret: "votre-vrai-tunnel-secret-vm1"

# Pour VM2 (web2)
cloudflared_tunnel_id2: "votre-vrai-tunnel-id-vm2"
cloudflared_hostname2: "scroll2.dgcf.ovh"
cloudflared_credentials2:
  AccountTag: "votre-vrai-account-tag"
  TunnelID: "votre-vrai-tunnel-id-vm2"
  TunnelSecret: "votre-vrai-tunnel-secret-vm2"
```

### 3. Comment obtenir ces valeurs

Voir `CLOUDFLARED_README.md` pour les instructions détaillées.

**Rappel des commandes principales :**

```bash
# Lister les tunnels
cloudflared tunnel list

# Obtenir les credentials
cloudflared tunnel token nom-du-tunnel
```

## ⚠️ Sécurité

- `vars.local.yml` est dans `.gitignore` - il ne sera jamais commité
- `vars.local.yml.example` sert de template et peut être commité
- Ne partagez jamais `vars.local.yml` avec qui que ce soit

## 🚀 Utilisation

Une fois `vars.local.yml` configuré :

```bash
# VM1
ansible-playbook -i inventory.ini ansible/playbook.yml

# VM2
ansible-playbook -i inventory.ini ansible/playbook2.yml
```

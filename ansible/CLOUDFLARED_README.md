# Configuration Cloudflared

## Prérequis

1. **Compte Cloudflare** avec domaine configuré
2. **Zero Trust activé** dans Cloudflare Dashboard

## Étapes de configuration

### 1. Créer les tunnels

Pour chaque VM, créez un tunnel nommé :

```bash
# Pour VM1
cloudflared tunnel create vm1-tunnel

# Pour VM2
cloudflared tunnel create vm2-tunnel
```

### 2. Récupérer les informations

Après création, listez les tunnels :

```bash
cloudflared tunnel list
```

Notez les IDs des tunnels.

### 3. Configurer les routes

Pour chaque tunnel, configurez la route vers votre domaine :

```bash
# Pour VM1
cloudflared tunnel route dns vm1-tunnel scroll.dgcf.ovh

# Pour VM2
cloudflared tunnel route dns vm2-tunnel scroll2.dgcf.ovh
```

### 4. Récupérer les credentials

Pour chaque tunnel, exportez les credentials :

```bash
# Pour VM1
cloudflared tunnel token vm1-tunnel

# Pour VM2
cloudflared tunnel token vm2-tunnel
```

Utilisez ces tokens pour générer les fichiers JSON de credentials.

### 5. Modifier vars.yml

Remplacez les valeurs dans `vars.yml` avec vos vraies informations.

## Lancement

```bash
# VM1
ansible-playbook -i inventory.ini ansible/playbook.yml

# VM2
ansible-playbook -i inventory.ini ansible/playbook2.yml
```

## Résultat

Vos VMs seront accessibles via :

- `https://scroll.dgcf.ovh` (VM1)
- `https://scroll2.dgcf.ovh` (VM2)

Le trafic passera par les tunnels Cloudflared de manière sécurisée.

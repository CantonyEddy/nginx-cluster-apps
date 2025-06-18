#!/bin/bash

set -e

# Nom des stacks à supprimer
STACKS=("nginx" "wekan" "monitoring" "debug")

echo "🧼 Suppression des stacks..."
for stack in "${STACKS[@]}"; do
  echo "→ docker stack rm $stack"
  docker stack rm "$stack" || true
done

echo "⏳ Attente 10s pour la suppression..."
sleep 10

echo "🧹 Suppression des containers restants (hors portainer)..."
docker ps -aq --filter "name=wekan" --filter "name=nginx" --filter "name=debug" | xargs -r docker rm -f

echo "🌐 Suppression du réseau nginx_web_overlay..."
docker network rm nginx_web_overlay || true

echo "🔧 Recréation du réseau propre..."
docker network create \
  --driver overlay \
  --attachable \
  --subnet 10.10.0.0/16 \
  nginx_web_overlay

echo "✅ Environnement nettoyé et prêt."
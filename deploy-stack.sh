#!/bin/bash

set -e

# === CONFIGURATION ===
SERVICES_DIR="services"
NGINX_DIR="nginx"
STACK_NAME=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function usage() {
  echo "Usage: $0 [service-name|all] [--dry-run]"
  exit 1
}

function deploy_service() {
  local svc="$1"
  local dry_run="$2"

  echo -e "${GREEN}==> Deploying service: $svc${NC}"

  # NGINX case
  if [[ "$svc" == "nginx" ]]; then
    file="$NGINX_DIR/nginx.yml"
    stack="nginx"
    [[ "$dry_run" == true ]] && echo "DRY-RUN: docker stack deploy -c $file $stack" || docker stack deploy -c "$file" "$stack"
    return
  fi

  # Other service (ex: wekan, blogango, etc.)
  stack="$svc"
  yml_files=$(find "$SERVICES_DIR/$svc" -type f -name "*.yml" | sort)

  for yml in $yml_files; do
    [[ "$dry_run" == true ]] && echo "DRY-RUN: docker stack deploy -c $yml $stack" || docker stack deploy -c "$yml" "$stack"
  done
}

# === MAIN ===
[[ $# -lt 1 ]] && usage

ARG="$1"
DRY_RUN=false

[[ "$2" == "--dry-run" ]] && DRY_RUN=true

if [[ "$ARG" == "all" ]]; then
  echo -e "${GREEN}Deploying all services...${NC}"
  deploy_service "nginx" $DRY_RUN
  for svc in $(ls "$SERVICES_DIR"); do
    deploy_service "$svc" $DRY_RUN
  done
else
  deploy_service "$ARG" $DRY_RUN
fi

if [[ "$DRY_RUN" == false ]]; then
  echo -e "${GREEN}Deployment completed.${NC}"
  docker service ls
fi

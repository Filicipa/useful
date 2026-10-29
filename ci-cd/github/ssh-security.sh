### create /usr/local/bin/deploy.sh

#!/usr/bin/env bash
set -euo pipefail

IMAGE="/home/ubuntu/compound-integration-api-dev"
COMPOSE="/home/ubuntu/backend/compose.yaml"

upload() {
    cat > "${IMAGE}.tmp"
    mv -f "${IMAGE}.tmp" "${IMAGE}.tar"
    docker load -i "${IMAGE}.tar"
}

deploy_api() {
    docker compose -f "$COMPOSE" up -d --no-deps api
}

deploy_worker() {
    docker compose -f "$COMPOSE" up -d --no-deps worker
}

prune_old_images() {
    docker image prune -af
}

case "${SSH_ORIGINAL_COMMAND:-}" in
    upload)           upload ;;
    deploy-api)       deploy_api ;;
    deploy-worker)    deploy_worker ;;
    prune-old-images) prune_old_images ;;
    *)
        echo "Permission denied" >&2
        exit 1
        ;;
esac

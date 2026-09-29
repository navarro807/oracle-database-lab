#!/usr/bin/env bash
set -euo pipefail

source scripts/deployment/env/00-config.sh

if tmux has-session -t ords 2>/dev/null; then
  echo "ORDS ya esta en marcha dentro de la sesion tmux: ords"
else
  tmux new-session -d -s ords \
    "$ORDS_HOME/bin/ords --config $ORDS_CONFIG serve"
  echo "ORDS arrancado en segundo plano, sesion tmux: ords"
fi

sleep 5
curl -sI "http://localhost:$ORDS_PORT/ords/" | head -n 1

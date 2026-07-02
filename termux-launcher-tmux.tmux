#!/system/bin/sh

CURRENT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

tmux run-shell "$CURRENT_DIR/scripts/config.tmux"
tmux run-shell "$CURRENT_DIR/scripts/material-theme.tmux"
tmux run-shell -b "sleep 1; $CURRENT_DIR/scripts/material-theme.tmux"

#!/data/data/com.termux/files/usr/bin/sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
theme="$(tmux show-option -gqv @termux-launcher-tmux-theme 2>/dev/null || printf 'rounded')"
[ -n "$theme" ] || theme=rounded

case "$theme" in
	rounded|sleek|purem3) ;;
	*) theme=rounded ;;
esac

"${script_dir}/themes/${theme}.tmux"

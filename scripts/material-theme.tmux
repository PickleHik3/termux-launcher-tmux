#!/data/data/com.termux/files/usr/bin/sh

set -eu

colors_sh="${HOME}/.termux/material-colors.sh"
colors_properties="${HOME}/.termux/material-colors.properties"

if [ -r "$colors_sh" ]; then
	. "$colors_sh"
elif [ -r "$colors_properties" ]; then
	while IFS='=' read -r key value; do
		case "$key" in
			''|\#*) continue ;;
		esac
		name=$(printf '%s' "$key" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
		eval "TERMUX_MATERIAL_${name}=\$value"
	done < "$colors_properties"
else
	exit 0
fi

surface=${TERMUX_MATERIAL_SURFACE:-#0F1512}
surface_container=${TERMUX_MATERIAL_SURFACE_CONTAINER:-$surface}
surface_container_high=${TERMUX_MATERIAL_SURFACE_CONTAINER_HIGH:-$surface_container}
surface_container_highest=${TERMUX_MATERIAL_SURFACE_CONTAINER_HIGHEST:-$surface_container_high}
surface_variant=${TERMUX_MATERIAL_SURFACE_VARIANT:-$surface_container_highest}
on_surface=${TERMUX_MATERIAL_ON_SURFACE:-#DEE4DE}
on_surface_variant=${TERMUX_MATERIAL_ON_SURFACE_VARIANT:-$on_surface}
outline_variant=${TERMUX_MATERIAL_OUTLINE_VARIANT:-$surface_variant}
primary=${TERMUX_MATERIAL_PRIMARY:-#8CD5B3}
on_primary=${TERMUX_MATERIAL_ON_PRIMARY:-#003826}
secondary=${TERMUX_MATERIAL_SECONDARY:-#B3CCBE}
tertiary=${TERMUX_MATERIAL_TERTIARY:-#A5CCDF}
error=${TERMUX_MATERIAL_ERROR:-#F2B8B5}
widget_pill_bg=$surface_container_highest
prefix_bg=$secondary
prefix_fg=$surface
copy_bg=$tertiary
copy_fg=$surface
cwd_color=$outline_variant
window_inactive_fg=$on_surface_variant
window_active_fg=$primary
window_attention_fg=$tertiary

tmux set-option -g status-style "bg=${surface},fg=${on_surface}"
tmux set-option -g status-left-length 64
tmux set-option -g status-right-length 88
tmux set-option -g window-status-separator ""

tmux set-option -g @termux-launcher-tmux-left-normal " #[fg=${widget_pill_bg},bg=${surface}]#[fg=${primary},bg=${widget_pill_bg},bold] #S #[fg=${widget_pill_bg},bg=${surface}] "
tmux set-option -g @termux-launcher-tmux-left-prefix " #[fg=${prefix_bg},bg=${surface}]#[fg=${prefix_fg},bg=${prefix_bg},bold] PRFX #[fg=${prefix_bg},bg=${surface}] "
tmux set-option -g @termux-launcher-tmux-left-copy " #[fg=${copy_bg},bg=${surface}]#[fg=${copy_fg},bg=${copy_bg},bold] COPY #[fg=${copy_bg},bg=${surface}] "
tmux set-option -g status-left "#{?pane_in_mode,#{E:@termux-launcher-tmux-left-copy},#{?client_prefix,#{E:@termux-launcher-tmux-left-prefix},#{E:@termux-launcher-tmux-left-normal}}}"
tmux set-option -g status-right "#(kew-tmux-status)#[fg=${secondary},bg=${surface}]#{?window_zoomed_flag,ZOOM ,}#[fg=${widget_pill_bg},bg=${surface}]#[range=user|btop,fg=${primary},bg=${widget_pill_bg}]#(launcher-system-monitor cpu | tr -d '\n')#[range=none]#[fg=${on_surface_variant},bg=${widget_pill_bg}] · #[range=user|btop,fg=${secondary},bg=${widget_pill_bg}]#(launcher-system-monitor ram | tr -d '\n')#[range=none]#[fg=${on_surface_variant},bg=${widget_pill_bg}] · #[fg=${tertiary},bg=${widget_pill_bg}]#(launcher-weather-widget | tr -d '\n')#[fg=${widget_pill_bg},bg=${surface}] "
tmux set-option -g status-format[0] "#[align=left,bg=${surface}]#{T:status-left}#[fg=${cwd_color},bg=${surface},nobold]#{=/36/...:#{s|${HOME}|~|:pane_current_path}}#[align=right,bg=${surface}]#{T:status-right}"
tmux set-option -g status-format[1] "#[align=centre,bg=${surface}]#{W:#{T:window-status-format},#{T:window-status-current-format}}"
tmux set-option -gu status-format[2]
tmux set-option -g status 2
tmux set-option status 2

tmux bind-key -n MouseDown1Status run-shell 'case "#{mouse_status_range}" in btop) command -v mini-btop-shizuku >/dev/null 2>&1 && tmux new-window -n btop "mini-btop-shizuku" || tmux display-message "Run ~/setup-btop-rish first" ;; esac'

tmux set-window-option -g window-status-format "#[fg=${window_inactive_fg},bg=${surface},nobold,noitalics,nounderscore] #I:#W "
tmux set-window-option -g window-status-current-format "#[fg=${window_active_fg},bg=${surface},bold,noitalics,nounderscore] #I:#{pane_current_command} "
tmux set-window-option -g window-status-activity-style "fg=${window_attention_fg},bg=${surface},bold"
tmux set-window-option -g window-status-bell-style "fg=${error},bg=${surface},bold"

tmux set-option -g pane-border-style "fg=${outline_variant}"
tmux set-option -g pane-active-border-style "fg=${primary}"
tmux set-option -g display-panes-colour "$secondary"
tmux set-option -g display-panes-active-colour "$primary"

tmux set-option -g message-style "bg=${surface_container_highest},fg=${on_surface}"
tmux set-option -g message-command-style "bg=${surface_container_high},fg=${on_surface}"
tmux set-option -g mode-style "bg=${primary},fg=${on_primary},bold"
tmux set-window-option -g clock-mode-colour "$primary"

tmux set-option -g copy-mode-match-style "bg=${surface_variant},fg=${on_surface}"
tmux set-option -g copy-mode-current-match-style "bg=${tertiary},fg=${surface}"

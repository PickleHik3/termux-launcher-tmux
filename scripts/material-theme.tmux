#!/data/data/com.termux/files/usr/bin/sh

set -eu

theme_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

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

option_on() {
	case "$(tmux show-option -gqv "$1" 2>/dev/null || printf '%s' "$2")" in
		off|OFF|false|FALSE|0|no|NO) return 1 ;;
		*) return 0 ;;
	esac
}

kew_status=''
system_widgets=''
weather_widget=''
now_playing=''
resource_widgets=''
show_system_widgets=off
show_storage_widget=off
show_battery_widget=off
show_network_widget=off
show_cpu_temp_widget=off
show_battery_temp_widget=off

if option_on @termux-launcher-tmux-kew-status on; then
	kew_status="#(kew-tmux-status)"
fi

if option_on @termux-launcher-tmux-system-widgets on; then
	show_system_widgets=on
fi

if option_on @termux-launcher-tmux-weather on; then
	weather_widget="#[fg=${tertiary},bg=${widget_pill_bg}]#(launcher-weather-widget | tr -d '\n')"
fi

if option_on @termux-launcher-tmux-now-playing on; then
	now_playing="#[align=right fg=${tertiary},bg=${surface},nobold]#(kew-now-playing | tr -d '\n')"
fi

if option_on @termux-launcher-tmux-storage-widget off; then
	show_storage_widget=on
fi

if option_on @termux-launcher-tmux-battery-widget off; then
	show_battery_widget=on
fi

if option_on @termux-launcher-tmux-network-widget off; then
	show_network_widget=on
fi

if option_on @termux-launcher-tmux-cpu-temperature-widget off; then
	show_cpu_temp_widget=on
fi

if option_on @termux-launcher-tmux-battery-temperature-widget off; then
	show_battery_temp_widget=on
	show_battery_widget=on
fi

if [ "$show_system_widgets" = on ] || [ "$show_storage_widget" = on ] || [ "$show_battery_widget" = on ] || [ "$show_network_widget" = on ] || [ "$show_cpu_temp_widget" = on ] || [ "$show_battery_temp_widget" = on ]; then
	resource_widgets="#(TERMUX_LAUNCHER_TMUX_SHOW_SYSTEM='${show_system_widgets}' TERMUX_LAUNCHER_TMUX_SHOW_STORAGE='${show_storage_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY='${show_battery_widget}' TERMUX_LAUNCHER_TMUX_SHOW_NETWORK='${show_network_widget}' TERMUX_LAUNCHER_TMUX_SHOW_CPU_TEMP='${show_cpu_temp_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY_TEMP='${show_battery_temp_widget}' TERMUX_LAUNCHER_TMUX_SEPARATOR_FG='${on_surface_variant}' TERMUX_LAUNCHER_TMUX_INLINE_SEPARATOR_FG='${on_surface_variant}' TERMUX_LAUNCHER_TMUX_WIDGET_BG='${widget_pill_bg}' TERMUX_LAUNCHER_TMUX_CPU_FG='${primary}' TERMUX_LAUNCHER_TMUX_RAM_FG='${secondary}' TERMUX_LAUNCHER_TMUX_STORAGE_FG='${secondary}' TERMUX_LAUNCHER_TMUX_BATTERY_FG='${primary}' TERMUX_LAUNCHER_TMUX_NETWORK_FG='${tertiary}' TERMUX_LAUNCHER_TMUX_CPU_TEMP_FG='${error}' TERMUX_LAUNCHER_TMUX_BATTERY_TEMP_FG='${tertiary}' ${theme_dir}/resource-widget right | tr -d '\n')"
fi

if [ -n "$resource_widgets" ] && [ -n "$weather_widget" ]; then
	right_widgets="${resource_widgets}#[fg=${on_surface_variant},bg=${widget_pill_bg}] · ${weather_widget}"
else
	right_widgets="${resource_widgets}${weather_widget}"
fi

if [ -n "$right_widgets" ]; then
	right_pill="#[fg=${widget_pill_bg},bg=${surface}]${right_widgets}#[fg=${widget_pill_bg},bg=${surface}] "
else
	right_pill=''
fi

tmux set-option -g status-style "bg=${surface},fg=${on_surface}"
tmux set-option -g status-position top
tmux set-option -g status-interval 5
tmux set-option -g mouse on
tmux set-option mouse on
tmux set-option -g status-left-length 64
tmux set-option -g status-right-length 160
tmux set-option -g window-status-separator ""

tmux set-option -g @termux-launcher-tmux-left-normal " #[fg=${widget_pill_bg},bg=${surface}]#[fg=${primary},bg=${widget_pill_bg},bold] #S #[fg=${widget_pill_bg},bg=${surface}] "
tmux set-option -g @termux-launcher-tmux-left-prefix " #[fg=${prefix_bg},bg=${surface}]#[fg=${prefix_fg},bg=${prefix_bg},bold] PRFX #[fg=${prefix_bg},bg=${surface}] "
tmux set-option -g @termux-launcher-tmux-left-copy " #[fg=${copy_bg},bg=${surface}]#[fg=${copy_fg},bg=${copy_bg},bold] COPY #[fg=${copy_bg},bg=${surface}] "
tmux set-option -g status-left "#{?pane_in_mode,#{E:@termux-launcher-tmux-left-copy},#{?client_prefix,#{E:@termux-launcher-tmux-left-prefix},#{E:@termux-launcher-tmux-left-normal}}}"
tmux set-option -g status-right "${kew_status}#[fg=${secondary},bg=${surface}]#{?window_zoomed_flag,ZOOM ,}${right_pill}"
tmux set-option -g status-format[0] "#[align=left range=left bg=${surface}]#{T:status-left}#[norange fg=${cwd_color},bg=${surface},nobold]#{=/36/...:#{s|${HOME}|~|:pane_current_path}}#[align=right range=right bg=${surface}]#{T:status-right}#[norange]"
tmux set-option -g status-format[1] "#[list=on align=centre bg=${surface}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index}]#{T:window-status-format}#[norange],#[range=window|#{window_index} list=focus]#{T:window-status-current-format}#[norange]}#[nolist]${now_playing}"
tmux set-option -gu status-format[2]
tmux set-option -g status 2
tmux set-option status 2

tmux bind-key -n MouseDown1Status select-window -t =
tmux unbind-key -n MouseUp1Status 2>/dev/null || true
tmux unbind-key -n MouseDown1StatusRight 2>/dev/null || true
tmux unbind-key -n MouseUp1StatusRight 2>/dev/null || true

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

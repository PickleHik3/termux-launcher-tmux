#!/data/data/com.termux/files/usr/bin/sh

set -eu

theme_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

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

surface=${TERMUX_MATERIAL_TERMINAL_BACKGROUND:-${TERMUX_MATERIAL_SURFACE:-#0F1512}}
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
on_secondary=${TERMUX_MATERIAL_ON_SECONDARY:-$surface}
tertiary=${TERMUX_MATERIAL_TERTIARY:-#A5CCDF}
on_tertiary=${TERMUX_MATERIAL_ON_TERTIARY:-$surface}
error=${TERMUX_MATERIAL_ERROR:-#F2B8B5}
error_container=${TERMUX_MATERIAL_ERROR_CONTAINER:-$surface_variant}
terminal_green=${TERMUX_MATERIAL_TERMINAL_COLOR10:-$primary}
terminal_yellow=${TERMUX_MATERIAL_TERMINAL_COLOR11:-$secondary}
terminal_blue=${TERMUX_MATERIAL_TERMINAL_COLOR12:-$tertiary}
terminal_magenta=${TERMUX_MATERIAL_TERMINAL_COLOR13:-$tertiary}
terminal_cyan=${TERMUX_MATERIAL_TERMINAL_COLOR14:-$on_surface}

bar_bg=$surface
chip_bg=$surface_container_high
chip_bg_high=$surface_container_highest
chip_bg_active=$surface_variant
separator_color=$outline_variant
subtle_fg=$on_surface_variant
prefix_bg=$tertiary
prefix_fg=$surface
copy_bg=$terminal_yellow
copy_fg=$surface
session_bg=$primary
session_fg=$on_primary
window_inactive_fg=$tertiary
window_inactive_bg=$chip_bg
window_active_fg=$on_primary
window_active_bg=$primary
window_attention_fg=$terminal_yellow
window_attention_bg=$bar_bg
window_index_fg=$secondary
cpu_color=$primary
ram_color=$terminal_cyan
storage_color=$terminal_blue
battery_color=$terminal_green
temperature_color=$terminal_yellow
weather_color=$tertiary
zoom_color=$terminal_magenta
tai_color=$terminal_cyan

color_mode="$(tmux show-option -gqv @termux-launcher-tmux-color-mode 2>/dev/null || printf 'default')"
case "$color_mode" in
	pure-m3|pure_m3|purem3)
		subtle_fg=$secondary
		separator_color=$secondary
		prefix_bg=$secondary
		prefix_fg=$on_secondary
		copy_bg=$tertiary
		copy_fg=$on_tertiary
		session_bg=$primary
		session_fg=$on_primary
		window_inactive_fg=$tertiary
		window_active_fg=$on_primary
		window_active_bg=$primary
		window_attention_fg=$terminal_yellow
		window_attention_bg=$surface_variant
		window_index_fg=$secondary
		cpu_color=$primary
		ram_color=$terminal_green
		storage_color=$terminal_blue
		battery_color=$terminal_cyan
		temperature_color=$terminal_yellow
		weather_color=$tertiary
		zoom_color=$error
		tai_color=$secondary
		;;
esac

option_on() {
	case "$(tmux show-option -gqv "$1" 2>/dev/null || printf '%s' "$2")" in
		off|OFF|false|FALSE|0|no|NO) return 1 ;;
		*) return 0 ;;
	esac
}

status_position="$(tmux show-option -gqv @termux-launcher-tmux-status-position 2>/dev/null || printf 'top')"
case "$status_position" in
	bottom|BOTTOM) status_position=bottom ;;
	top|TOP|'') status_position=top ;;
	*) status_position=top ;;
esac

system_widgets=''
weather_widget=''
now_playing=''
resource_widgets=''
tai_widget=''
show_system_widgets=off
show_storage_widget=off
show_battery_widget=off
show_cpu_temp_widget=off
show_battery_temp_widget=off

if option_on @termux-launcher-tmux-system-widgets on; then
	show_system_widgets=on
fi

if option_on @termux-launcher-tmux-weather on; then
	weather_mode="$(tmux show-option -gqv @termux-launcher-tmux-weather-mode 2>/dev/null || printf 'compact')"
	[ -n "$weather_mode" ] || weather_mode=compact
	weather_widget="#[fg=${weather_color},bg=${chip_bg}]#(TERMUX_LAUNCHER_TMUX_WEATHER_MODE='${weather_mode}' ${theme_dir}/weather-widget | tr -d '\n')"
fi

if option_on @termux-launcher-tmux-now-playing on; then
	now_playing="#[align=right fg=${secondary},bg=${bar_bg},nobold] #(${theme_dir}/now-playing-widget | tr -d '\n') "
fi

if option_on @termux-launcher-tmux-storage-widget off; then
	show_storage_widget=on
fi

if option_on @termux-launcher-tmux-battery-widget off; then
	show_battery_widget=on
fi

if option_on @termux-launcher-tmux-cpu-temperature-widget off; then
	show_cpu_temp_widget=on
fi

if option_on @termux-launcher-tmux-battery-temperature-widget off; then
	show_battery_temp_widget=on
	show_battery_widget=on
fi

if [ "$show_system_widgets" = on ] || [ "$show_storage_widget" = on ] || [ "$show_battery_widget" = on ] || [ "$show_cpu_temp_widget" = on ] || [ "$show_battery_temp_widget" = on ]; then
	resource_widgets="#(TERMUX_LAUNCHER_TMUX_SHOW_SYSTEM='${show_system_widgets}' TERMUX_LAUNCHER_TMUX_SHOW_STORAGE='${show_storage_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY='${show_battery_widget}' TERMUX_LAUNCHER_TMUX_SHOW_CPU_TEMP='${show_cpu_temp_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY_TEMP='${show_battery_temp_widget}' TERMUX_LAUNCHER_TMUX_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_INLINE_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_WIDGET_BG='${chip_bg}' TERMUX_LAUNCHER_TMUX_CPU_FG='${cpu_color}' TERMUX_LAUNCHER_TMUX_RAM_FG='${ram_color}' TERMUX_LAUNCHER_TMUX_STORAGE_FG='${storage_color}' TERMUX_LAUNCHER_TMUX_BATTERY_FG='${battery_color}' TERMUX_LAUNCHER_TMUX_CPU_TEMP_FG='${temperature_color}' TERMUX_LAUNCHER_TMUX_BATTERY_TEMP_FG='${temperature_color}' ${theme_dir}/resource-widget right | tr -d '\n')"
fi

if [ -n "$resource_widgets" ] && [ -n "$weather_widget" ]; then
	right_widgets="${resource_widgets}#[fg=${separator_color},bg=${chip_bg}] · ${weather_widget}"
else
	right_widgets="${resource_widgets}${weather_widget}"
fi

if option_on @termux-launcher-tmux-tai on; then
	tai_has_next=off
	[ -n "$right_widgets" ] && tai_has_next=on
	tai_widget="#(TERMUX_LAUNCHER_TMUX_WIDGET_BG='${chip_bg}' TERMUX_LAUNCHER_TMUX_TAI_FG='${tai_color}' TERMUX_LAUNCHER_TMUX_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_TAI_TRAILING_SEPARATOR='${tai_has_next}' ${theme_dir}/tai-widget | tr -d '\n')"
	right_widgets="${tai_widget}${right_widgets}"
fi

if [ -n "$right_widgets" ]; then
	right_pill="#[fg=${chip_bg},bg=${bar_bg},nobold]#[fg=${on_surface},bg=${chip_bg},nobold] ${right_widgets} #[fg=${chip_bg},bg=${bar_bg},nobold] "
else
	right_pill=''
fi

tmux set-option -g status-style "bg=${bar_bg},fg=${on_surface}"
tmux set-option -g status-position "$status_position"
tmux set-option -g status-interval 5
tmux set-option -g mouse on
tmux set-option -g base-index 1
tmux set-window-option -g pane-base-index 1
tmux set-option -g renumber-windows on
tmux set-option -g status-left-length 72
tmux set-option -g status-right-length 180
tmux set-option -g window-status-separator ""

tmux set-option -g @termux-launcher-tmux-left-normal " #[fg=${session_bg},bg=${bar_bg},nobold]#[fg=${session_fg},bg=${session_bg},bold] #S #[fg=${session_bg},bg=${bar_bg},nobold] "
tmux set-option -g @termux-launcher-tmux-left-prefix " #[fg=${prefix_bg},bg=${bar_bg},nobold]#[fg=${prefix_fg},bg=${prefix_bg},bold] PREFIX #[fg=${prefix_bg},bg=${bar_bg},nobold] "
tmux set-option -g @termux-launcher-tmux-left-copy " #[fg=${copy_bg},bg=${bar_bg},nobold]#[fg=${copy_fg},bg=${copy_bg},bold] COPY #[fg=${copy_bg},bg=${bar_bg},nobold] "
tmux set-option -g status-left "#{?pane_in_mode,#{E:@termux-launcher-tmux-left-copy},#{?client_prefix,#{E:@termux-launcher-tmux-left-prefix},#{E:@termux-launcher-tmux-left-normal}}}"
tmux set-option -g status-right "#[fg=${zoom_color},bg=${bar_bg},bold]#{?window_zoomed_flag, ZOOM ,}${right_pill}"
tmux set-option -g status-format[0] "#[align=left range=left bg=${bar_bg}]#{T:status-left}#[align=right range=right bg=${bar_bg}]#{T:status-right}#[norange]"
tmux set-option -g status-format[1] "#[list=on align=centre bg=${bar_bg}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index}]#{T:window-status-format}#[norange],#[range=window|#{window_index} list=focus]#{T:window-status-current-format}#[norange]}#[nolist]${now_playing}"
tmux set-option -gu status-format[2]
tmux set-option -u status-format[2] 2>/dev/null || true
tmux set-option -g status 2
tmux set-option status 2

tmux bind-key -n MouseDown1Status select-window -t =
tmux unbind-key -n MouseUp1Status 2>/dev/null || true
tmux unbind-key -n MouseDown1StatusRight 2>/dev/null || true
tmux unbind-key -n MouseUp1StatusRight 2>/dev/null || true

tmux set-window-option -g window-status-format " #[fg=${window_inactive_bg},bg=${bar_bg},nobold]#[fg=${window_index_fg},bg=${window_inactive_bg},nobold,noitalics,nounderscore] #I #[fg=${window_inactive_fg},bg=${window_inactive_bg},nobold]#W #[fg=${window_inactive_bg},bg=${bar_bg}]"
tmux set-window-option -g window-status-current-format " #[fg=${window_active_bg},bg=${bar_bg},nobold]#[fg=${window_active_fg},bg=${window_active_bg},bold,noitalics,nounderscore] #I #W #[fg=${window_active_bg},bg=${bar_bg},nobold]"
tmux set-window-option -g window-status-activity-style "fg=${window_attention_fg},bg=${window_attention_bg},nobold"
tmux set-window-option -g window-status-bell-style "fg=${error},bg=${error_container},nobold"

tmux set-option -g pane-border-style "fg=${outline_variant}"
tmux set-option -g pane-active-border-style "fg=${primary}"
tmux set-option -g pane-border-lines single
tmux set-option -g pane-border-indicators off
tmux set-option -g pane-border-status off
tmux set-option -g display-panes-colour "$secondary"
tmux set-option -g display-panes-active-colour "$primary"

tmux set-option -g message-style "bg=${chip_bg_active},fg=${on_surface}"
tmux set-option -g message-command-style "bg=${chip_bg_high},fg=${on_surface}"
tmux set-option -g mode-style "bg=${primary},fg=${on_primary},nobold"
tmux set-window-option -g clock-mode-colour "$primary"

tmux set-option -g copy-mode-match-style "bg=${surface_variant},fg=${on_surface}"
tmux set-option -g copy-mode-current-match-style "bg=${tertiary},fg=${bar_bg}"

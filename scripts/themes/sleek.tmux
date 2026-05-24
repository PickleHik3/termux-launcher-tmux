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
fi

bar_bg=default
surface=${TERMUX_MATERIAL_TERMINAL_BACKGROUND:-${TERMUX_MATERIAL_SURFACE:-default}}
surface_variant=${TERMUX_MATERIAL_SURFACE_VARIANT:-colour236}
on_surface=${TERMUX_MATERIAL_ON_SURFACE:-colour245}
on_surface_variant=${TERMUX_MATERIAL_ON_SURFACE_VARIANT:-colour245}
outline_variant=${TERMUX_MATERIAL_OUTLINE_VARIANT:-colour236}
primary=${TERMUX_MATERIAL_PRIMARY:-${TERMUX_MATERIAL_TERMINAL_COLOR9:-red}}
on_primary=${TERMUX_MATERIAL_ON_PRIMARY:-default}
secondary=${TERMUX_MATERIAL_SECONDARY:-${TERMUX_MATERIAL_TERMINAL_COLOR14:-colour245}}
tertiary=${TERMUX_MATERIAL_TERTIARY:-${TERMUX_MATERIAL_TERMINAL_COLOR12:-blue}}
error=${TERMUX_MATERIAL_ERROR:-${TERMUX_MATERIAL_TERMINAL_COLOR9:-red}}
warning=${TERMUX_MATERIAL_TERMINAL_COLOR11:-yellow}
terminal_green=${TERMUX_MATERIAL_TERMINAL_COLOR10:-green}
terminal_blue=${TERMUX_MATERIAL_TERMINAL_COLOR12:-blue}
terminal_cyan=${TERMUX_MATERIAL_TERMINAL_COLOR14:-$on_surface}

muted=$on_surface_variant
border=$primary
separator_color=$secondary
text=$on_surface
subtle=$on_surface_variant
session_bg=$primary
session_fg=$on_primary
prefix_fg=$tertiary
copy_fg=$warning
window_inactive_fg=$muted
window_active_fg=$primary
window_attention_fg=$warning
window_index_fg=$secondary
cpu_color=$primary
ram_color=$terminal_cyan
storage_color=$terminal_blue
battery_color=$terminal_green
temperature_color=$warning
weather_color=$tertiary
zoom_color=$primary

option_on() {
	case "$(tmux show-option -gqv "$1" 2>/dev/null || printf '%s' "$2")" in
		off|OFF|false|FALSE|0|no|NO) return 1 ;;
		*) return 0 ;;
	esac
}

weather_widget=''
now_playing=''
resource_widgets=''
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
	weather_widget="#[fg=${weather_color},bg=${bar_bg},nobold]#(TERMUX_LAUNCHER_TMUX_WEATHER_MODE='${weather_mode}' ${theme_dir}/weather-widget | tr -d '\n')"
fi

if option_on @termux-launcher-tmux-now-playing on; then
	now_playing="#[fg=${subtle},bg=${bar_bg},nobold] #(${theme_dir}/now-playing-widget | tr -d '\n')"
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
	resource_widgets="#(TERMUX_LAUNCHER_TMUX_SHOW_SYSTEM='${show_system_widgets}' TERMUX_LAUNCHER_TMUX_SHOW_STORAGE='${show_storage_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY='${show_battery_widget}' TERMUX_LAUNCHER_TMUX_SHOW_CPU_TEMP='${show_cpu_temp_widget}' TERMUX_LAUNCHER_TMUX_SHOW_BATTERY_TEMP='${show_battery_temp_widget}' TERMUX_LAUNCHER_TMUX_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_INLINE_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_WIDGET_BG='${bar_bg}' TERMUX_LAUNCHER_TMUX_CPU_FG='${cpu_color}' TERMUX_LAUNCHER_TMUX_RAM_FG='${ram_color}' TERMUX_LAUNCHER_TMUX_STORAGE_FG='${storage_color}' TERMUX_LAUNCHER_TMUX_BATTERY_FG='${battery_color}' TERMUX_LAUNCHER_TMUX_CPU_TEMP_FG='${temperature_color}' TERMUX_LAUNCHER_TMUX_BATTERY_TEMP_FG='${temperature_color}' ${theme_dir}/resource-widget right | tr -d '\n')"
fi

right_widgets="$resource_widgets"
if [ -n "$right_widgets" ] && [ -n "$weather_widget" ]; then
	right_widgets="${right_widgets}#[fg=${separator_color},bg=${bar_bg}] · ${weather_widget}"
else
	right_widgets="${right_widgets}${weather_widget}"
fi
right_widgets="${right_widgets}${now_playing}"

tmux set-option -g status on
tmux set-option -g status-position top
tmux set-option -g status-interval 5
tmux set-option -g status-style "bg=${bar_bg},fg=${muted}"
tmux set-option -g status-left-length 12
tmux set-option -g status-right-length 42
tmux set-option -g status-justify left
tmux set-option -g window-status-separator ""
tmux set-option -g status-left "#[fg=${session_fg},bg=${session_bg},bold] #S #[fg=${separator_color},bg=${bar_bg},nobold]"
tmux set-option -g status-right "#[fg=${zoom_color},bg=${bar_bg},bold]#{?window_zoomed_flag, ZOOM ,}#[fg=${text},bg=${bar_bg},nobold]${right_widgets}"
tmux set-option -g status-format[0] "#[bg=${bar_bg}]#[fg=${session_fg},bg=${session_bg},bold] #S #[fg=${separator_color},bg=${bar_bg},nobold]#{W:#[range=window|#{window_index}]#{T:window-status-format}#[norange],#[range=window|#{window_index}]#{T:window-status-current-format}#[norange]}#[align=right bg=${bar_bg}]#[fg=${zoom_color},bg=${bar_bg},bold]#{?window_zoomed_flag, ZOOM ,}#[fg=${text},bg=${bar_bg},nobold]${right_widgets}"
tmux set-option -gu status-format[1]
tmux set-option -gu status-format[2]

tmux bind-key -n MouseDown1Status select-window -t =
tmux unbind-key -n MouseUp1Status 2>/dev/null || true
tmux unbind-key -n MouseDown1StatusRight 2>/dev/null || true
tmux unbind-key -n MouseUp1StatusRight 2>/dev/null || true

tmux set-window-option -g window-status-format "#[fg=${window_index_fg},bg=${bar_bg},nobold,noitalics,nounderscore] #I#[fg=${window_inactive_fg},bg=${bar_bg},nobold]:#{pane_current_command} "
tmux set-window-option -g window-status-current-format "#[fg=${window_active_fg},bg=${bar_bg},bold,noitalics,nounderscore] #I:#{pane_current_command} "
tmux set-window-option -g window-status-current-style "fg=${window_active_fg},bg=${bar_bg},bold"
tmux set-window-option -g window-status-activity-style "fg=${warning},bg=${bar_bg},nobold"
tmux set-window-option -g window-status-bell-style "fg=${error},bg=${bar_bg},bold"

tmux set-option -g pane-border-style "fg=#{?#{==:#{client_key_table},prefix},${prefix_fg},${border}}"
tmux set-option -g pane-active-border-style "fg=#{?pane_in_mode,${copy_fg},#{?#{==:#{client_key_table},prefix},${prefix_fg},${border}}}"
tmux set-option -g pane-border-lines heavy
tmux set-option -g pane-border-indicators off
tmux set-option -g pane-border-format "#{?pane_in_mode, COPY ,#{?#{==:#{client_key_table},prefix}, PRFX , ↓ #{?@name,#{@name},#{b:pane_current_path}} }}"
tmux set-option -g pane-border-status top
tmux set-option -g display-panes-colour "$muted"
tmux set-option -g display-panes-active-colour "$primary"

tmux set-option -g message-style "bg=${bar_bg},fg=${text}"
tmux set-option -g message-command-style "bg=${bar_bg},fg=${text}"
tmux set-option -g mode-style "bg=${primary},fg=${on_primary},bold"
tmux set-window-option -g clock-mode-colour "$primary"
tmux set-option -g copy-mode-match-style "bg=default,fg=${warning}"
tmux set-option -g copy-mode-current-match-style "bg=${primary},fg=${on_primary}"

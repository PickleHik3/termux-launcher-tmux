#!/system/bin/sh

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
on_secondary=${TERMUX_MATERIAL_ON_SECONDARY:-default}
tertiary=${TERMUX_MATERIAL_TERTIARY:-${TERMUX_MATERIAL_TERMINAL_COLOR12:-blue}}
on_tertiary=${TERMUX_MATERIAL_ON_TERTIARY:-default}
error=${TERMUX_MATERIAL_ERROR:-${TERMUX_MATERIAL_TERMINAL_COLOR9:-red}}
warning=${TERMUX_MATERIAL_TERMINAL_COLOR11:-yellow}
terminal_green=${TERMUX_MATERIAL_TERMINAL_COLOR10:-green}
terminal_yellow=${TERMUX_MATERIAL_TERMINAL_COLOR11:-yellow}
terminal_blue=${TERMUX_MATERIAL_TERMINAL_COLOR12:-blue}
terminal_magenta=${TERMUX_MATERIAL_TERMINAL_COLOR13:-magenta}
terminal_cyan=${TERMUX_MATERIAL_TERMINAL_COLOR14:-$on_surface}
terminal_bright_black=${TERMUX_MATERIAL_TERMINAL_COLOR8:-$on_surface_variant}

muted=$terminal_bright_black
border=$secondary
separator_color=$secondary
text=$on_surface
subtle=$on_surface_variant
session_bg=$primary
session_fg=$on_primary
prefix_fg=$primary
copy_fg=$terminal_yellow
window_inactive_fg=$tertiary
window_inactive_bg=$bar_bg
window_active_fg=$tertiary
window_active_bg=$bar_bg
window_attention_fg=$warning
window_attention_bg=$bar_bg
window_index_fg=$secondary
cpu_color=$primary
ram_color=$terminal_green
storage_color=$terminal_blue
battery_color=$terminal_cyan
temperature_color=$terminal_yellow
weather_color=$tertiary
zoom_color=$terminal_magenta
tai_color=$terminal_cyan

color_mode="$(tmux show-option -gqv @termux-launcher-tmux-color-mode 2>/dev/null || printf 'default')"
case "$color_mode" in
	pure-m3|pure_m3|purem3)
		muted=$on_surface_variant
		border=$tertiary
		separator_color=$secondary
		text=$on_surface
		subtle=$on_surface_variant
		session_bg=$primary
		session_fg=$on_primary
		prefix_fg=$secondary
		copy_fg=$tertiary
		window_active_fg=$on_secondary
		window_active_bg=$secondary
		window_inactive_fg=$tertiary
		window_index_fg=$secondary
		window_attention_fg=$terminal_yellow
		window_attention_bg=$surface_variant
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

pane_path_arrow='↓'
pane_border_status=top
if [ "$status_position" = bottom ]; then
	pane_path_arrow='↑'
	pane_border_status=bottom
fi

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

if option_on @termux-launcher-tmux-tai on; then
	tai_has_next=off
	[ -n "$right_widgets" ] && tai_has_next=on
	tai_widget="#(TERMUX_LAUNCHER_TMUX_WIDGET_BG='${bar_bg}' TERMUX_LAUNCHER_TMUX_TAI_FG='${tai_color}' TERMUX_LAUNCHER_TMUX_SEPARATOR_FG='${separator_color}' TERMUX_LAUNCHER_TMUX_TAI_TRAILING_SEPARATOR='${tai_has_next}' ${theme_dir}/tai-widget | tr -d '\n')"
	right_widgets="${tai_widget}${right_widgets}"
fi

right_widgets="${right_widgets}${now_playing}"

tmux set-option -g status on
tmux set-option status on
tmux set-option -g status-position "$status_position"
tmux set-option -g status-interval 5
tmux set-option -g status-style "bg=${bar_bg},fg=${muted}"
tmux set-option -g status-left-length 12
tmux set-option -g status-right-length 42
tmux set-option -g status-justify left
tmux set-option -g window-status-separator ""
tmux set-option -g status-left "#[fg=${session_fg},bg=${session_bg},bold] #S"
tmux set-option -g status-right "#[fg=${zoom_color},bg=${bar_bg},bold]#{?window_zoomed_flag, ZOOM ,}#[fg=${text},bg=${bar_bg},nobold]${right_widgets}"
tmux set-option -g status-format[0] "#[bg=${bar_bg}]#[fg=${session_fg},bg=${session_bg},bold] #S #{W:#[range=window|#{window_index}]#{T:window-status-format}#[norange],#[range=window|#{window_index}]#{T:window-status-current-format}#[norange]}#[align=right bg=${bar_bg}]#[fg=${zoom_color},bg=${bar_bg},bold]#{?window_zoomed_flag, ZOOM ,}#[fg=${text},bg=${bar_bg},nobold]${right_widgets}"
tmux set-option -gu status-format[1]
tmux set-option -gu status-format[2]
tmux set-option -u status-format[1] 2>/dev/null || true
tmux set-option -u status-format[2] 2>/dev/null || true

tmux bind-key -n MouseDown1Status select-window -t =
tmux unbind-key -n MouseUp1Status 2>/dev/null || true
tmux unbind-key -n MouseDown1StatusRight 2>/dev/null || true
tmux unbind-key -n MouseUp1StatusRight 2>/dev/null || true

tmux set-window-option -g window-status-format "#[fg=${window_index_fg},bg=${window_inactive_bg},nobold,noitalics,nounderscore] #I#[fg=${window_inactive_fg},bg=${window_inactive_bg},nobold]:#{pane_current_command} "
tmux set-window-option -g window-status-current-format "#[fg=${window_active_fg},bg=${window_active_bg},bold,noitalics,nounderscore] #I:#{pane_current_command} "
tmux set-window-option -g window-status-current-style "fg=${window_active_fg},bg=${window_active_bg},bold"
tmux set-window-option -g window-status-activity-style "fg=${window_attention_fg},bg=${window_attention_bg},nobold"
tmux set-window-option -g window-status-bell-style "fg=${error},bg=${bar_bg},bold"

tmux set-option -g pane-border-style "fg=#{?#{==:#{client_key_table},prefix},${prefix_fg},${border}}"
tmux set-option -g pane-active-border-style "fg=#{?pane_in_mode,${copy_fg},#{?#{==:#{client_key_table},prefix},${prefix_fg},${border}}}"
tmux set-option -g pane-border-lines single
tmux set-option -g pane-border-indicators off
tmux set-option -g pane-border-format "#{?pane_in_mode, COPY ,#{?#{==:#{client_key_table},prefix}, PRFX , ${pane_path_arrow} #{?@name,#{@name},#{b:pane_current_path}} }}"
tmux set-option -g pane-border-status "$pane_border_status"
tmux set-option -g display-panes-colour "$muted"
tmux set-option -g display-panes-active-colour "$tertiary"

tmux set-option -g message-style "bg=${bar_bg},fg=${text}"
tmux set-option -g message-command-style "bg=${bar_bg},fg=${text}"
tmux set-option -g mode-style "bg=${tertiary},fg=${bar_bg},bold"
tmux set-window-option -g clock-mode-colour "$tertiary"
tmux set-option -g copy-mode-match-style "bg=default,fg=${terminal_yellow}"
tmux set-option -g copy-mode-current-match-style "bg=${tertiary},fg=${bar_bg}"

#!/usr/bin/env sh

# Prefix
tmux set-option -g prefix C-Space
tmux set-option -g prefix2 C-b
tmux bind-key C-Space send-prefix

# Reload and Termux settings
tmux bind-key q source-file "$HOME/.tmux.conf" \; display "Configuration reloaded"
tmux bind-key F12 run-shell 'termux-reload-settings >/dev/null 2>&1; tmux display-message "Termux settings reloaded"'

# Copy mode
tmux set-window-option -g mode-keys vi
tmux bind-key -T copy-mode-vi v send -X begin-selection
tmux bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

# Pane controls
tmux bind-key h split-window -v -c "#{pane_current_path}"
tmux bind-key v split-window -h -c "#{pane_current_path}"
tmux bind-key x kill-pane

tmux bind-key -n C-M-Left select-pane -L
tmux bind-key -n C-M-Right select-pane -R
tmux bind-key -n C-M-Up select-pane -U
tmux bind-key -n C-M-Down select-pane -D

tmux bind-key -n C-M-S-Left resize-pane -L 5
tmux bind-key -n C-M-S-Down resize-pane -D 5
tmux bind-key -n C-M-S-Up resize-pane -U 5
tmux bind-key -n C-M-S-Right resize-pane -R 5

# Window navigation
tmux bind-key r command-prompt -I "#W" "rename-window -- '%%'"
tmux bind-key c new-window -c "#{pane_current_path}"
tmux bind-key k kill-window

tmux bind-key -n M-1 select-window -t 1
tmux bind-key -n M-2 select-window -t 2
tmux bind-key -n M-3 select-window -t 3
tmux bind-key -n M-4 select-window -t 4
tmux bind-key -n M-5 select-window -t 5
tmux bind-key -n M-6 select-window -t 6
tmux bind-key -n M-7 select-window -t 7
tmux bind-key -n M-8 select-window -t 8
tmux bind-key -n M-9 select-window -t 9

tmux bind-key -n M-Left select-window -t -1
tmux bind-key -n M-Right select-window -t +1
tmux bind-key -n M-S-Left swap-window -t -1 \; select-window -t -1
tmux bind-key -n M-S-Right swap-window -t +1 \; select-window -t +1

# Session controls
tmux bind-key R command-prompt -I "#S" "rename-session -- '%%'"
tmux bind-key C new-session -c "#{pane_current_path}"
tmux bind-key K kill-session
tmux bind-key P switch-client -p
tmux bind-key N switch-client -n

tmux bind-key -n M-Up switch-client -p
tmux bind-key -n M-Down switch-client -n

# General tmux defaults for Termux Launcher
tmux set-option -g default-terminal "tmux-256color"
tmux set-option -ag terminal-overrides ",*:RGB"
tmux set-option -g mouse on
tmux set-option -g base-index 1
tmux set-window-option -g pane-base-index 1
tmux set-option -g renumber-windows on
tmux set-option -g history-limit 50000
tmux set-option -g escape-time 0
tmux set-option -g focus-events on
tmux set-option -g set-clipboard on
tmux set-option -g allow-passthrough on
tmux set-window-option -g aggressive-resize on
tmux set-option -g detach-on-destroy off
tmux set-option -g extended-keys on
tmux set-option -g extended-keys-format csi-u
tmux set-option -sg escape-time 10

tmux set-window-option -g automatic-rename on
tmux set-window-option -g automatic-rename-format '#{b:pane_current_path}'

# Launcher app shortcuts
tmux bind-key -n M-w run-shell 'tmux display-message "Opening WhatsApp"; launcherctl launch whatsapp >/dev/null 2>&1 || tmux display-message "Launch failed: WhatsApp"'
tmux bind-key -n M-k run-shell 'tmux display-message "Opening komikku"; launcherctl launch komikku >/dev/null 2>&1 || tmux display-message "Launch failed: komikku"'
tmux bind-key -n M-b run-shell 'tmux display-message "Opening cromite"; launcherctl launch cromite >/dev/null 2>&1 || tmux display-message "Launch failed: cromite"'
tmux bind-key -n M-g run-shell 'tmux display-message "Opening gallery"; launcherctl launch gallery >/dev/null 2>&1 || tmux display-message "Launch failed: gallery"'
tmux bind-key -n M-s run-shell 'tmux display-message "Opening settings"; launcherctl launch settings >/dev/null 2>&1 || tmux display-message "Launch failed: settings"'
tmux bind-key -n M-r run-shell 'tmux display-message "Opening reddit"; launcherctl launch reddit >/dev/null 2>&1 || tmux display-message "Launch failed: reddit"'
tmux bind-key -n M-i run-shell 'tmux display-message "Opening instagram"; launcherctl launch instagram >/dev/null 2>&1 || tmux display-message "Launch failed: instagram"'
tmux bind-key -n M-f run-shell 'tmux display-message "Opening solidexplorer"; launcherctl launch solidexplorer >/dev/null 2>&1 || tmux display-message "Launch failed: solidexplorer"'
tmux bind-key -n M-y run-shell 'tmux display-message "Opening youtube"; launcherctl launch youtube >/dev/null 2>&1 || tmux display-message "Launch failed: youtube"'

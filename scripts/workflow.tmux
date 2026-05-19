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
tmux bind-key -n MouseDown1Status select-window -t =

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

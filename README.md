# termux-launcher-tmux

Material You tmux workflow and theme for [Termux Launcher](https://github.com/PickleHik3/termux-launcher).

![termux-launcher-tmux screenshot](assets/screenshot.png)

## Install With TPM

Install TPM first if you do not already use it:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Add the plugin near the bottom of `~/.tmux.conf`:

```tmux
set -g @plugin 'PickleHik3/termux-launcher-tmux'

run '~/.tmux/plugins/tpm/tpm'
```

Reload tmux, then press `prefix + I` to install plugins:

```sh
tmux source-file ~/.tmux.conf
```

## Requirements

- tmux 3.6 or newer
- a Nerd Font in Termux
- Termux Launcher Material colors at `~/.termux/material-colors.sh` or `~/.termux/material-colors.properties`
- optional helper commands on `PATH`:
  - `launcher-system-monitor`
  - `launcher-weather-widget`
  - `kew-now-playing`

The helper commands are documented in the Termux Launcher [tmux status setup](https://github.com/PickleHik3/termux-launcher/blob/dev/docs/en/Launcher_Tmux_Status_Setup.md).

## User Options

Set any of these before the TPM line in `~/.tmux.conf`, then reload tmux.

```tmux
# Theme defaults to "rounded". Use "sleek" for the smux-inspired minimal bar.
set -g @termux-launcher-tmux-theme rounded

# Core widgets default to "on".
set -g @termux-launcher-tmux-system-widgets on
set -g @termux-launcher-tmux-weather on
set -g @termux-launcher-tmux-now-playing on

# Weather display: compact shows "󰖔 37°"; condition shows "󰖔 37° Sunny".
set -g @termux-launcher-tmux-weather-mode compact

# Extra resource widgets default to "off".
set -g @termux-launcher-tmux-storage-widget off
set -g @termux-launcher-tmux-battery-widget off
set -g @termux-launcher-tmux-cpu-temperature-widget off
set -g @termux-launcher-tmux-battery-temperature-widget off
```

Turn widgets off individually:

```tmux
set -g @termux-launcher-tmux-system-widgets off
set -g @termux-launcher-tmux-weather off
set -g @termux-launcher-tmux-now-playing off
```

Switch to the smux-inspired theme:

```tmux
set -g @termux-launcher-tmux-theme sleek
```

Show the weather condition text:

```tmux
set -g @termux-launcher-tmux-weather-mode condition
```

Turn extra resource widgets on individually:

```tmux
set -g @termux-launcher-tmux-storage-widget on
set -g @termux-launcher-tmux-battery-widget on
set -g @termux-launcher-tmux-cpu-temperature-widget on
set -g @termux-launcher-tmux-battery-temperature-widget on
```

The extra widgets read `launcherctl resources`.

## Controls

The default prefix is `Ctrl+Space`. `Ctrl+b` is also available as a fallback.

### Help And Reload

| Key | Action |
| --- | --- |
| `Alt+e` | Show the keybind reference popup |
| `prefix q` | Reload `~/.tmux.conf` |
| `F12` | Reload Termux settings with `termux-reload-settings` |

### Panes

| Key | Action |
| --- | --- |
| `prefix h` | Split below, starting in the current pane path |
| `prefix v` | Split right, starting in the current pane path |
| `prefix x` | Kill the current pane |
| `Ctrl+Alt+Arrow` | Move focus between panes |
| `Ctrl+Alt+Shift+Arrow` | Resize the current pane |

### Windows

| Key | Action |
| --- | --- |
| `prefix c` | Create a new window in the current pane path |
| `prefix k` | Kill the current window |
| `prefix r` | Rename the current window |
| `Alt+1` ... `Alt+9` | Jump to window 1 through 9 |
| `Alt+Left` / `Alt+Right` | Previous / next window |
| `Alt+Shift+Left` / `Alt+Shift+Right` | Move the current window left / right |
| Touch/click a window name | Select that window |

### Sessions

| Key | Action |
| --- | --- |
| `prefix Shift+c` | Create a new session in the current pane path |
| `prefix Shift+r` | Rename the current session |
| `prefix Shift+k` | Kill the current session |
| `Alt+Up` / `Alt+Down` | Previous / next session |
| `prefix Shift+p` / `prefix Shift+n` | Previous / next session |

### Copy Mode

| Key | Action |
| --- | --- |
| `prefix [` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection and leave copy mode |

## App Shortcut Examples

The plugin does not install app-launch shortcuts by default. Add only the shortcuts you want to your own `~/.tmux.conf`. In tmux config syntax, `M-` means `Alt+`.

```tmux
bind -n M-w run-shell 'tmux display-message "Opening WhatsApp"; launcherctl launch whatsapp >/dev/null 2>&1 || tmux display-message "Launch failed: WhatsApp"'
bind -n M-y run-shell 'tmux display-message "Opening YouTube"; launcherctl launch youtube >/dev/null 2>&1 || tmux display-message "Launch failed: YouTube"'
bind -n M-b run-shell 'tmux display-message "Opening Browser"; launcherctl launch cromite >/dev/null 2>&1 || tmux display-message "Launch failed: Browser"'
```

Change the app ids to match your `launcherctl apps` output.

## What It Does

- Installs the Termux Launcher tmux keybinds and options: prefix, pane/window/session navigation, copy-mode keys, help popup, and `F12` settings reload.
- Uses Termux Launcher's Material color exports and maps them to Material-style roles: neutral surfaces for structure, primary for focus, secondary/tertiary for supporting signal, and error only for alerts.
- Defaults to the `rounded` theme, a compact two-row tmux status bar for Android screens.
- Provides a `sleek` theme inspired by smux: one top status row plus a labeled pane-border row, default terminal background, simple `#I:#W` windows, and Material-colored text widgets without chip backgrounds.
- In `rounded`, shows session, prefix, and copy mode as elevated Material-style chips on the left.
- Shows CPU, RAM, optional resource widgets, zoom state, and compact or condition weather in the active theme style.
- Can optionally add storage, battery, CPU temperature, and battery temperature widgets.
- Shows windows from the left edge of the second row, with the focused window showing the active process name.
- Shows the current `kew` track on the far right of the second row only while playback is active.

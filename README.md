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
- Termux Launcher Material colors at `~/.termux/material-colors.sh`
- optional helper commands on `PATH`:
  - `launcher-system-monitor`
  - `launcher-weather-widget`
  - `kew-tmux-status`
  - `kew-now-playing`

The helper commands are documented in the Termux Launcher [tmux status setup](https://github.com/PickleHik3/termux-launcher/blob/dev/docs/en/Launcher_Tmux_Status_Setup.md).

## What It Does

- Installs the Termux Launcher tmux workflow keybinds: prefix, pane/window/session navigation, copy-mode keys, app launcher shortcuts, and `F12` settings reload.
- Uses Termux Launcher's Material color exports.
- Shows a compact two-row tmux status bar for Android screens.
- Shows `PRFX` and `COPY` state pills on the left.
- Shows the current directory as a muted `~/...` path.
- Shows CPU, RAM, and weather in a rounded right-side pill.
- Shows windows on the second row, with the focused window showing the active process name.
- Shows `kew-now-playing` on the far right of the second row when it has content.

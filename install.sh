#!/usr/bin/env bash
# Install: curl -fsSL https://raw.githubusercontent.com/SwapnilChand/wifi-keepalive/main/install.sh | bash
# Remove:  ... | bash -s -- --uninstall
set -eu
BIN=$HOME/.local/bin/wifi-keepalive
UNITS=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user
INTERVAL=${WIFI_KEEPALIVE_INTERVAL:-5min}

if [ "${1:-}" = --uninstall ]; then
  systemctl --user disable --now wifi-keepalive.timer 2>/dev/null || true
  rm -f "$BIN" "$UNITS"/wifi-keepalive.{service,timer}
  systemctl --user daemon-reload
  echo "uninstalled"; exit
fi

mkdir -p "${BIN%/*}" "$UNITS"
src=$(dirname "${BASH_SOURCE[0]:-.}")/wifi-keepalive
if [ -f "$src" ]; then cp "$src" "$BIN"
else curl -fsSL https://raw.githubusercontent.com/SwapnilChand/wifi-keepalive/main/wifi-keepalive -o "$BIN"; fi
chmod +x "$BIN"

cat > "$UNITS/wifi-keepalive.service" <<UNIT
[Unit]
Description=Captive portal wifi keepalive
[Service]
Type=oneshot
ExecStart=$BIN
UNIT
cat > "$UNITS/wifi-keepalive.timer" <<UNIT
[Unit]
Description=Run wifi-keepalive every $INTERVAL
[Timer]
OnBootSec=1min
OnUnitActiveSec=$INTERVAL
[Install]
WantedBy=timers.target
UNIT

systemctl --user daemon-reload
systemctl --user enable --now wifi-keepalive.timer
echo "installed. log: tail -f ~/.local/state/wifi-keepalive.log"

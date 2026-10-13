# wifi-keepalive

Linux-only. Keeps captive-portal cafe wifi (Third Wave Coffee and other MikroTik hotspots) from dropping you, and tells you when it needs a login. That matters on Linux, where the login page often never pops up.

Every minute (and right after waking from sleep) it:
- hits `http://connectivitycheck.gstatic.com/generate_204`. The traffic keeps the session from going idle.
- logs `online` / `offline` / `captive <login-url>`, plus the hotspot's `connected / left` timer if the router exposes one.
- if you got kicked back to the login page, loads it the way a browser refresh would. Many portals (MikroTik mac-cookie) log you back in automatically from that. If they don't, you get a desktop notification with the login URL.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/SwapnilChand/wifi-keepalive/main/install.sh | bash
```

Requires `curl` and systemd. Change the interval with `WIFI_KEEPALIVE_INTERVAL="*:0/5" (systemd OnCalendar syntax)` before running the installer.

```sh
tail -f ~/.local/state/wifi-keepalive.log   # watch it
wifi-keepalive                               # check once by hand
curl -fsSL https://raw.githubusercontent.com/SwapnilChand/wifi-keepalive/main/install.sh | bash -s -- --uninstall
```

## Why sessions drop

MikroTik hotspots usually grant a long session (e.g. `172d` left) but drop hosts that go quiet: idle timeout, or no ARP/ping reply while the laptop sleeps. Periodic traffic covers the first case. Sleep can't be prevented, so the tool re-logs you in on wake.

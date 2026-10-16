#!/bin/bash
# mac-randomize — randomize your Wi-Fi MAC on macOS
# usage: sudo ./mac-randomize.sh [interface]
#   interface defaults to whatever device sits under the Wi-Fi hardware port
# note: change doesn't survive a reboot, which is the point
set -euo pipefail

mapfile -t IFACES < <(networksetup -listallhardwareports | awk '/^Hardware Port: Wi-Fi$/{getline; print $2}')

if ((${#IFACES[@]} == 0)); then
  echo "no Wi-Fi interface found — pass one explicitly" >&2
  exit 1
elif ((${#IFACES[@]} == 1)); then
  IFACE="${1:-${IFACES[0]}}"
else
  echo "multiple Wi-Fi interfaces found:"
  select IFACE in "${IFACES[@]}"; do
    [[ -n "$IFACE" ]] && break
  done
fi

rand_mac() {
  # 6 random bytes; first octet forced locally-administered + unicast
  local b first
  b=$(openssl rand -hex 6)
  first=$(( 0x${b:0:2} & 0xFE | 0x02 ))
  printf '%02x:%s:%s:%s:%s:%s' "$first" "${b:2:2}" "${b:4:2}" "${b:6:2}" "${b:8:2}" "${b:10:2}"
}

OLD_MAC=$(ifconfig "$IFACE" | awk '/ether/{print $2}')
NEW_MAC=$(rand_mac)

echo "interface: $IFACE"
echo "old MAC:   $OLD_MAC"

echo "dropping wifi..."
networksetup -setairportpower "$IFACE" off
sleep 1

echo "setting new MAC: $NEW_MAC"
ifconfig "$IFACE" ether "$NEW_MAC"

echo "rejoining..."
networksetup -setairportpower "$IFACE" on
sleep 2

CUR=$(ifconfig "$IFACE" | awk '/ether/{print $2}')
echo "current MAC: $CUR"
if [[ "$CUR" == "$NEW_MAC" ]]; then
  echo "done, you're a new device as far as the captive portal cares"
else
  echo "failed — still showing $CUR"
  exit 1
fi

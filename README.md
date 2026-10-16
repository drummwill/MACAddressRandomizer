# MACAddressRandomizer

Randomize your Wi-Fi MAC address on macOS. The network sees a new device each time — handy for privacy on public networks and for getting a fresh timer out of captive portals with time limits.

## Usage

```sh
chmod +x mac-randomize.sh
sudo ./mac-randomize.sh [interface]
```

- The interface is auto-detected from the Wi-Fi hardware port — no args needed on a normal Mac.
- Pass one explicitly if you have opinions: `sudo ./mac-randomize.sh en1`
- If multiple Wi-Fi interfaces ever show up, you get a menu instead of a guess.

## How it works

1. Drops Wi-Fi (`networksetup -setairportpower off`) — macOS won't let you change the MAC on a live interface.
2. Sets a random MAC (`ifconfig <iface> ether <mac>`).
3. Rejoins Wi-Fi.

The generated MAC is locally-administered + unicast (first octet forced to `x2`/`x6`/`xA`/`xE`), so you're not impersonating a real vendor OUI.

## Notes

- Needs sudo — changing a MAC is a privileged op.
- Doesn't survive a reboot. The original MAC comes back, which is the point.
- Modern macOS does this natively per-network: Settings > Wi-Fi > (i) on the network > Private Wi-Fi address > Rotating. This script is the on-demand hammer.

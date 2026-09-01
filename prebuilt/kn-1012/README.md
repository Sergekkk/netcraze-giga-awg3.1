# Prebuilt Binaries for Keenetic Giga (KN-1012)

This directory contains (or is designated for) ready-to-use binaries for:
- **Device**: Keenetic Giga (KN-1012)
- **SoC**: MediaTek MT7981B (Filogic 820) / Cortex-A53 (aarch64)
- **KeeneticOS**: 5.01.C.4.0-1 (Linux kernel 4.9.337-ndm-5)
- **AmneziaWG Version**: 3.1.x (protocol version 3 with full obfuscation headers: `Jc`, `Jmin`, `Jmax`, `S1`, `S2`, `H1`–`H4`)

## Expected Files in this Directory:

1. `amneziawg.ko` — compiled Linux kernel module (loaded via `/opt/sbin/insmod` into router's kernel).
2. `awg` — cross-compiled user-space command-line tool.

## Extraction / Copying:

If you already built or downloaded these binaries, place them directly into this folder:
```bash
cp /path/to/amneziawg.ko prebuilt/kn-1012/
cp /path/to/awg prebuilt/kn-1012/
```

When running `router/install.sh`, it will automatically copy these files into `/opt/lib/modules/amneziawg.ko` and `/opt/bin/awg`.

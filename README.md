# iSH Toolkit

A small, menu-driven Alpine package installer for **iSH on iOS**.

This is **not Kali Linux** and does not turn iSH into a full Linux machine. iSH runs an Alpine userland in an emulated environment, so some packages may be missing, incompatible, slow, or unable to use kernel/network features.

## Quick start

In iSH:

```sh
apk update
apk add git
git clone https://github.com/Velzak/ish-toolkit.git
cd ish-toolkit
sh install.sh
```

Or download the repository ZIP from GitHub, extract it in iSH's Files area, then run `sh install.sh` from that directory.

## Install categories

```sh
sh install.sh basics
sh install.sh dev
sh install.sh python
sh install.sh network
sh install.sh security
sh install.sh text
sh install.sh media
```

To attempt every package:

```sh
sh install.sh all
```

The `all` option asks for confirmation first. Package installs are attempted one at a time so one unavailable package does not stop the rest. Review `install.log` for details.

## Included categories

| Category | What's inside |
|---|---|
| Basics | Shells, core utilities, file tools |
| Development | Git, compilers, build tools, language runtimes |
| Python | Python and commonly used libraries |
| Network | DNS, routing, ping, traceroute, WHOIS, connectivity diagnostics |
| Security | TLS, encryption, hashing, and defensive auditing utilities |
| Text/data | JSON/YAML and text conversion |
| Media | Archives, sync, and FFmpeg |

The package lists are curated candidates, not a promise that every package exists for every iSH release. Availability depends on the Alpine repositories and architecture bundled with your iSH installation.

## Useful scripts

- `install.sh` — category menu or command-line installer
- `update.sh` — refresh package indexes and upgrade installed packages
- `check.sh` — show Alpine version and which listed packages are installed

## iSH limitations

- iSH is not a standard Linux kernel environment.
- Tools that need raw sockets, kernel modules, Wi-Fi monitor mode, USB device access, system services, or privileged networking may not work.
- A package installing successfully does not guarantee every feature works in iSH.
- If `apk update` fails, check the Alpine release and repository configuration before changing repositories. Don't blindly point an old Alpine install at a different release.
- Large packages can use significant storage. Install categories selectively if space is tight.

## Safety / intended use

This project focuses on general development, administration, diagnostics, encryption, and defensive auditing. Use network tools only on systems and networks you own or have explicit permission to test. It does not include password spraying, brute-force automation, exploit launchers, or stealth/persistence tooling.

## License

MIT — see [LICENSE](LICENSE).
<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&pause=1000&color=61DAFB&center=true&vCenter=true&width=600&lines=Hi%2C+I'm+lazy...;so+my+PC+does+the+work+for+me.;Welcome+to+my+i3wm+setup.;Light.+Fast.+No+bloat." alt="Typing SVG" />

![i3wm](https://img.shields.io/badge/WM-i3-blue?style=for-the-badge&logo=i3&logoColor=white)
![Arch](https://img.shields.io/badge/Arch-Linux-1793D1?style=for-the-badge&logo=archlinux&logoColor=white)
![Lightweight](https://img.shields.io/badge/Lightweight-yes-brightgreen?style=for-the-badge)

</div>

---

## About

A lazy person's i3wm setup — built to be **light enough that it doesn't need a status bar plugin, a compositor with a hundred effects, or a heavy DE riding along in the background.** Everything here is picked because it's small, fast, and does exactly one job well.

## Screenshots

<p align="center">
  <img src="examples/pic_1.png" width="45%" />
  <img src="examples/pic_2.png" width="45%" />
</p>

---

## Packages

Only **`legcord`** needs the AUR — everything else is in Arch's official repos.

**Using pacman** (official repo packages):
```bash
sudo pacman -S i3-wm rofi kitty picom dunst pipewire wireplumber thunar scrot gammastep xwallpaper zed
```

**Using yay** (covers the AUR-only package, plus everything above works through yay too):
```bash
yay -S i3-wm rofi kitty picom dunst pipewire wireplumber thunar scrot gammastep xwallpaper zed legcord
```

> **Important:** never run `yay` with `sudo`, and never build AUR packages as root — `makepkg` refuses to run as root outright, so it's not a workaround that "just needs more permission." If `yay` throws a permission error, `sudo yay ...` is not the fix; it's almost always a stale build cache (`yay -Sc`) or a missing `base-devel` group (`sudo pacman -S base-devel`). `pacman`, on the other hand, always needs `sudo` — that's just normal system package installation, nothing to route around.

| Package | What it's for |
|---|---|
| **i3-wm** | The window manager itself — uses the **built-in i3bar** for the status bar, no polybar/waybar needed. This is the main reason the whole setup stays this light. |
| **rofi** | App launcher / menu |
| **kitty** | Terminal emulator |
| **picom** | Compositor — handles transparency and screen-tearing fixes |
| **dunst** | Notification daemon |
| **pipewire** + **wireplumber** | Audio server + the `wpctl` command used for volume control |
| **thunar** | File manager — **not a hard requirement**, swap in whatever file manager you like |
| **scrot** | Screenshots |
| **gammastep** | Screen color temperature / warmth control |
| **xwallpaper** | Sets the wallpaper |
| **zed** | Code editor |
| **legcord** (AUR) | Discord client — works well, but I'm not 100% sold it's the *best* option out there, so feel free to swap it |

> Note: package names above are correct at time of writing — always sanity-check with `pacman -Ss <name>` / `yay -Ss <name>` if something doesn't resolve, since names occasionally change.

---

## Features & Keybinds

`$mod` is set to **Mod4** (the Super/Windows key) throughout.

**No status bar plugin needed.** The config leans on i3's own built-in i3bar (`~/.config/i3/bar.sh`) instead of something like polybar — one less background process, one less thing to configure, and it's plenty for a minimal setup.

**Brightness control (even on monitors that don't support it).** Some displays don't expose real hardware brightness control. Instead of skipping that feature, `brightness.sh` fakes it by dimming the screen with a dark overlay — works everywhere, no hardware dependency. Adjust the dim strength directly inside `~/.config/services/brightness.sh`.

**Wallpaper (via `xwallpaper`).** Wallpapers fade-cycle smoothly using `~/.config/services/wallshift.sh`. It caches every fade transition to disk the first time it's seen, so after the first cycle through your wallpapers it costs basically zero CPU on repeats — good for weak/no-GPU hardware.

Wallpapers are pulled from a folder set at the top of the script:
```bash
WALLPAPER_DIR="${WALLSHIFT_DIR:-$HOME/Pictures/Wallpapers}"
```
Change that path (or export `WALLSHIFT_DIR` before running the script) to point at your own wallpaper folder — needs at least 2 images in there to have anything to fade between.

### Keybinds

| Keys | Action |
|---|---|
| `$mod+t` | Open terminal (kitty) |
| `$mod+d` | App launcher (rofi) |
| `$mod+q` | Kill focused window |
| `$mod+j` / `k` / `l` / `;` | Focus left / down / up / right |
| `$mod+Shift+j/k/l/;` | Move focused window left / down / up / right |
| `$mod+h` / `v` | Split horizontal / vertical |
| `$mod+f` | Fullscreen toggle |
| `$mod+s` / `w` / `e` | Layout: stacking / tabbed / toggle split |
| `$mod+Shift+space` | Floating toggle |
| `$mod+space` | Focus mode toggle (tiling ↔ floating) |
| `$mod+a` | Focus parent container |
| `$mod+1`–`0` | Switch to workspace 1–10 |
| `$mod+Shift+1`–`0` | Move focused window to workspace 1–10 |
| `$mod+r` | Enter resize mode (then `j/k/l/;` or arrows, `Enter`/`Escape`/`$mod+r` to exit) |
| `$mod+Shift+c` | Reload i3 config |
| `$mod+Shift+r` | Restart i3 in place |
| `$mod+Shift+e` | Exit i3 (with confirmation prompt) |
| `Ctrl+=` | Volume up 5% |
| `Ctrl+-` | Volume down 5% |
| `Ctrl+m` | Mute toggle |
| `Print` | Screenshot full screen → `~/Pictures/ss/` |
| `Shift+Print` | Screenshot select region → `~/Pictures/ss/` |
| `Ctrl+Shift+=` | Brightness up |
| `Ctrl+Shift+-` | Brightness down |
| `Ctrl+d` | Toggle warm mode (`gammastep -O 5000`) |
| `Alt+s` | Start screen recorder |

Volume and mute use `wpctl` directly on the default audio sink and fire a notification via `dunst` showing the new level. Screenshots and brightness/warm-mode binds all live near the bottom of the i3 config if you want to remap keys or change save paths.

---

## Installation

```bash
git clone git@github.com:lazzy-amrit/my-dotfiles.git
cd my-dotfiles
```
if the Above don't work then try this 

```bash
git clone https://github.com/lazzy-amrit/my-dotfiles.git
cd my-dotfiles
```

Then symlink or copy the folders you want into `~/.config/`, install the packages above, and restart i3 (`$mod+Shift+r`) to load everything.

---

<div align="center">

Made by someone too lazy to run a heavy DE — and that's the whole point.

</div>

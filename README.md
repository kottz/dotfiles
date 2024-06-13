<p align=center>
    <h3 align=center>My configurations: sway, nvim etc.</h3>
</p>

# Installation
Clone into `~/.dotfiles`. It is important that this repository is placed in 
the home directory since [stow](https://www.gnu.org/software/stow/) is used to
create appropiate symlinks.

```bash
git clone https://github.com/kottz/dotfiles ~/.dotfiles
```

The sway config requires you to create a file called `monitor` in `gui/.config/sway/` containing your monitor setup. E.g.
```
output eDP-1 resolution 1920x1080 position 1920,0
output HDMI-A-2 resolution 1920x1080 position 0,0
```
In addition, a wallpaper symlink called `wallpaper` must be created in `gui/.config/sway/`.

```bash
ln -s ~/wallpaper/best_wallpaper.png ~/.dotfiles/gui/.config/sway/wallpaper
```

Once these files are created the configs can be installed with
```bash
stow editor gui shell scripts env
```
## Dependencies
```bash
ttf-font-awesome ttf-jetbrains-mono network-manager-applet ripgrep fd foot aerc waybar sway nvim tofi tmux wlogout yazi
```

The nvim config also requires
```bash
cargo install proximity-sort
```

# Notes
- I use [Colemak](https://colemak.com/) so all applications are configured accordingly.

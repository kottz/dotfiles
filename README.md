<p align=center>
    <h3 align=center>My configurations: sway, vim etc.</h3>
</p>

This repository contains configuration files for many programs that I regularly use on a day to day basis.
 - [`alacritty`](https://github.com/alacritty/alacritty)
 - [`nvim`](https://neovim.io/)
 - [`ranger`](https://github.com/ranger/ranger)
 - [`sway`](https://swaywm.org)
 - [`waybar`](https://github.com/Alexays/Waybar)


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
stow editor gui shell scrips
```
## Dependencies
```bash
ttf-font-awesome network-manager-applet
```

Start nm-applet with the systemd user service
```bash
systemctl --user enable nm-applet.service
```

# Notes
- I use [Colemak](https://colemak.com/) so all applications are configured accordingly.
- [Base16](https://github.com/chriskempson/base16) is used for themes. 
Currently using `horizon-dark`. Configurations for different themes can be 
found in the different <code>base16-*application*</code> repositories.

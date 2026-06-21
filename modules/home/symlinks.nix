{config, ...}: let
  dotfiles = "${config.home.homeDirectory}/.nixos-dotfiles/config";
  qs = "${dotfiles}/quickshell";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    wal = "wal";
    mpv = "mpv";
    cava = "cava";
    nvim = "nvim";
    yazi = "yazi";
    rmpc = "rmpc";
    kitty = "kitty";
    vesktop = "vesktop";
    scripts = "scripts";
    starship = "starship";
    fastfetch = "fastfetch";
  };
in {
  xdg.configFile = {
    "hypr/hypridle.conf".source = create_symlink "${dotfiles}/hypr/hypridle.conf";
    "hypr/hyprlock.conf".source = create_symlink "${dotfiles}/hypr/hyprlock.conf";
    "hypr/hyprland.lua".source = create_symlink "${dotfiles}/hypr/hyprland.lua";
    "hypr/hyprland".source = create_symlink "${dotfiles}/hypr/hyprland";
    "hypr/hyprland".recursive = true;

    # Quickshell — symlink subdirectories individually so agenix can manage token files
    "quickshell/assets".source = create_symlink "${qs}/assets";
    "quickshell/assets".recursive = true;
    "quickshell/components".source = create_symlink "${qs}/components";
    "quickshell/components".recursive = true;
    "quickshell/files".source = create_symlink "${qs}/files";
    "quickshell/files".recursive = true;
    "quickshell/scripts".source = create_symlink "${qs}/scripts";
    "quickshell/scripts".recursive = true;
    "quickshell/services".source = create_symlink "${qs}/services";
    "quickshell/services".recursive = true;
    "quickshell/state".source = create_symlink "${qs}/state";
    "quickshell/state".recursive = true;
    "quickshell/Colors.qml".source = create_symlink "${qs}/Colors.qml";
    "quickshell/Animations.qml".source = create_symlink "${qs}/Animations.qml";
    "quickshell/shell.qml".source = create_symlink "${qs}/shell.qml";
    "quickshell/UIState.qml".source = create_symlink "${qs}/UIState.qml";
    "quickshell/qmldir".source = create_symlink "${qs}/qmldir";
  }
  // (builtins.mapAttrs
      (name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs)
  // {
    "gtk-3.0/gtk.css".enable = false;
    "gtk-4.0/gtk.css".enable = false;
  };
}

{ config, pkgs, pkgs-unstable, quickshell, ... }: {
  imports = [
    ./modules/home/browsers
    ./modules/home/desktop
    ./modules/home/dev
    ./modules/home/media
    ./modules/home/shell
    ./modules/home/packages.nix
    ./modules/home/symlinks.nix
  ];

  home.username = "s4m8";
  home.homeDirectory = "/home/s4m8";
  home.stateVersion = "26.05";

  home.packages = [
    pkgs.opencode
  ];
}

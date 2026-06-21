{
  pkgs,
  pkgs-unstable,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs-unstable.hyprland;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
    withUWSM = false; # Disable UWSM integration
  };
  programs.appimage.enable = true;
  programs.nix-ld.enable = true;
}

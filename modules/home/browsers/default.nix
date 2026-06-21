{ pkgs, ... }: {
  programs.brave = {
    enable = true;
    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; }  # Bitwarden
      { id = "chphlpgkkbolifaimnlloiipkdnihall"; }  # OneTab
    ];
    commandLineArgs = [
      "--password-store=gnome-libsecret"
      "--ozone-platform-hint=auto"
    ];
  };
}

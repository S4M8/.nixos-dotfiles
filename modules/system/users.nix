{pkgs, ...}: {
  users.users.s4m8 = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    packages = with pkgs; [tree];
  };
  security.sudo.extraRules = [
    {
      users = ["s4m8"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start wg-quick-surfshark";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop wg-quick-surfshark";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
  environment.sessionVariables = {
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    WLR_GAMMA_CONTROL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };
}

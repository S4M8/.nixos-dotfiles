{ ... }: {
  networking.wg-quick.interfaces.surfshark = {
    configFile = "/etc/wireguard/surfshark.conf";
    autostart = false;
  };
}

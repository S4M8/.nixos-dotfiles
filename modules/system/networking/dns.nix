{...}: {
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSOverTLS = "opportunistic";
      DNSSEC = "true";
      DNS = [ "1.1.1.1" "9.9.9.9" ];
    };
  };
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
}

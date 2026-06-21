{ config, lib, pkgs, ... }:
let
  home = config.users.users.s4m8.home;
in {
  age.secrets = {
    quickshell-tmdb-token = {
      file = ../../secrets/quickshell-tmdb-token.age;
      path = "${home}/.config/quickshell-secrets/tmdb_token";
      owner = "s4m8";
      group = "users";
      mode = "600";
    };
    quickshell-anilist-token = {
      file = ../../secrets/quickshell-anilist-token.age;
      path = "${home}/.config/quickshell-secrets/anilist_token";
      owner = "s4m8";
      group = "users";
      mode = "600";
    };
    quickshell-tmdb-account-id = {
      file = ../../secrets/quickshell-tmdb-account-id.age;
      path = "${home}/.config/quickshell-secrets/tmdb_account_id";
      owner = "s4m8";
      group = "users";
      mode = "600";
    };
  };
}

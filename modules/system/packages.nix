{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # archives
    zip
    xz
    unzip
    p7zip
    # utils
    ripgrep
    jq
    fzf
    btop
    ntfs3g
    killall
    openssl
    pciutils
    lshw
    smartmontools
    wl-clipboard
    cliphist
    wget
    curl
    brightnessctl
    libnotify
    networkmanagerapplet
    openssh
    nh
    bat
    # file management
    gvfs
    mtpfs
    jmtpfs
    libmtp
    usbutils
    thunar
    tumbler
    thunar-volman
    thunar-archive-plugin
    # desktop
    obsidian
    vesktop
    discord
    brave
    typst
    libreoffice
    tdf
    # sddm theme
    qt6.qt5compat
    qt6.qtimageformats
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "pink";
      font = "JetBrainsMono Nerd Font";
      fontSize = "10";
    })
    # screenshot / recording
    grim
    slurp
    wf-recorder
    # python (for quickshell notification daemon + servers)
    (python3.withPackages (ps: with ps; [
      dbus-python
      pygobject3
      requests
    ]))
    # terminal
    kitty
    # dev
    git
    # media
    playerctl
    mpd
    mpc
    mpd-mpris
    cava
    rmpc
    ffmpeg
    imagemagick
    awww
    # fonts
    nerd-fonts.jetbrains-mono
  ];
}

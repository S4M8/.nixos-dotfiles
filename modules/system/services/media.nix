{...}: {
  services.mpd = {
    enable = true;
    startWhenNeeded = true;
    user = "s4m8";
    settings = {
      music_directory = "/home/s4m8/music";
      auto_update = "yes";
      audio_output = [
        {
          type = "pipewire";
          name = "PipeWire Output";
        }
        {
          type = "fifo";
          name = "my_fifo";
          path = "/tmp/mpd.fifo";
          format = "44100:16:2";
        }
      ];
    };
  };
  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/1000";
  };
}

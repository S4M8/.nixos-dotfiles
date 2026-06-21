{...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "S4M8";
        email = "matt.urrea.code@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}

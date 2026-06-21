{pkgs, ...}: {
  home.packages = with pkgs; [
    nil
    biome
    stylua
    zed-editor
    neovim
    alejandra
    prettierd
    lua-language-server
    prettier
  ];
}

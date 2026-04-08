{...}: {
  flake.homeModules.zsh = {
    config,
    pkgs,
    inputs,
    ...
  }: let
    http_proxy = "http://192.168.0.50:3128";
    nrsAlias =
      if config.programs.nh.enable
      then "nh os switch .#NixosSystem.desktop"
      else "sudo nixos-rebuild switch --flake .#desktop";
  in {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "jonathan";
        plugins = ["git"];
      };
    };

    home.shellAliases = {
      proxyrun = "HTTP_PROXY=${http_proxy} http_proxy=${http_proxy} HTTPS_PROXY=${http_proxy} https_proxy=${http_proxy}";
      nrs = nrsAlias;
    };
  };
}

{...}: {
  flake.homeModules.chromium = {pkgs,...}: {
    programs.chromium = {
      enable = true;

      commandLineArgs = [
        "--force-dark-mode"
      ];


      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" 
        "padekgcemlokbadohgkifijomclgjgif" 
      ];
    };
  };
}

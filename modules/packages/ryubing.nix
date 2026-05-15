{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.ryujinxCanary = pkgs.ryujinx.overrideAttrs (oldAttrs: {
      version = "1.3.293";
      src = pkgs.fetchFromGitLab {
        domain = "git.ryujinx.app";
        owner = "Ryubing";
        repo = "Canary";
        tag = "1.3.293";
        hash = "sha256-LhQaXxmj5HIgfmrsDN8GhhVXlXHpDO2Q8JtNLaAAAAA=";
      };
    });
  };
}

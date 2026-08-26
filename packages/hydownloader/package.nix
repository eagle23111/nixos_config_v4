{
  pkgs,
  lib,
  python313,
  gallery-dl,
}: let
  python = python313;
in
  python.pkgs.buildPythonApplication {
    pname = "hydownloader";
    version = "0.78.0";

    src = builtins.fetchGit {
      url = "https://gitgud.io/thatfuckingbird/hydownloader";
      rev = "e37f2bd85702d1bee4650961968acb194aacc115";
      ref = "master";
    };

    nativeBuildInputs = [
      python.pkgs.poetry-core
    ];
    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'gallery-dl (>=1.32.8,<2.0.0)' 'gallery-dl' \
        --replace-fail 'click (>=8.3.2,<9.0.0)' 'click' \
        --replace-fail 'hydrus-api (>=5.2.1,<6.0.0)' 'hydrus-api' \
        --replace-fail 'poetry-core>=2.0.0,<3.0.0' 'poetry-core'
    '';
    propagatedBuildInputs = [
      python.pkgs.click
      python.pkgs.bottle
      python.pkgs.yt-dlp
      (python.pkgs.hydrus-api.overrideAttrs (old: {
        version = "5.3.0";
        src = pkgs.fetchPypi {
          pname = "hydrus_api";
          version = "5.3.0";
          hash = "sha256-Xq27pMVj2JkcHLvFzVDKL9KNOjTxZ3yH5+RVcVMzKJc=";
        };
      }))
      python.pkgs.python-dateutil
      python.pkgs.requests
      python.pkgs.cheroot
      python.pkgs.brotli
      gallery-dl
      python.pkgs.pillow
      python.pkgs.pysocks
      python.pkgs.yt-dlp-ejs
      # Transitive dependencies often required explicitly if build fails:
      python.pkgs.certifi
      python.pkgs.idna
      python.pkgs.charset-normalizer
      python.pkgs.urllib3
      python.pkgs.six
      python.pkgs.numpy
      python.pkgs.packaging
    ];

    pyproject = true;

    meta = with lib; {
      description = "Download stuff like Hydrus does.";
      homepage = "https://gitgud.io/thatfuckingbird/hydownloader";
      mainProgram = "hydl";
      license = licenses.agpl3Plus;
    };
  }

{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    python = pkgs.python313;
    hydownloader = python.pkgs.buildPythonApplication {
      pname = "hydownloader";
      version = "0.71.0";

      src = builtins.fetchGit {
        url = "https://gitgud.io/thatfuckingbird/hydownloader";
        rev = "ec551b9ac54bd869eea232f236fefd5ef4758426";
        ref = "master";
      };

      nativeBuildInputs = [
        python.pkgs.poetry-core
      ];
      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail 'build-backend = "poetry.masonry.api"' \
                         'build-backend = "poetry.core.masonry.api"' \
          --replace-fail 'poetry>=' 'poetry-core>=' \
          --replace-fail 'gallery-dl = "^1.31.10"' 'gallery-dl = "^1.30.10"' \
          --replace-fail 'pillow = "^11.0.0"' 'pillow = "^12.2.0"'
      '';

      propagatedBuildInputs = [
        python.pkgs.click
        python.pkgs.bottle
        python.pkgs.yt-dlp
        python.pkgs.hydrus-api
        python.pkgs.python-dateutil
        python.pkgs.requests
        python.pkgs.brotli
        (pkgs.gallery-dl.overrideAttrs (old: {
          version = "1.31.9";
          src = pkgs.fetchFromGitHub {
            owner = "mikf";
            repo = "gallery-dl";
            tag = "v1.31.9";
            hash = "sha256-Dq4SSj78CEZ4hq3jCgzcJK/+KPgn7h52HMfFNDQXQPY=";
          };
        }))
        /*
          (python.pkgs.pillow.overrideAttrs (old: {
          version = "11.3.0";
          src = pkgs.fetchFromGitHub {
            owner = "python-pillow";
            repo = "pillow";
            tag = "11.3.0";
            hash = "sha256-VOOIxzTyERI85CvA2oIutybiivU14kIko8ysXpmwUN8=";
          };
        }))
        */
        python.pkgs.pillow
        python.pkgs.pysocks
        python.pkgs.yt-dlp-ejs
        #  (python.pkgs.yt-dlp-ejs.overrideAttrs (old: {
        #version = "0.8.0";
        #     src = pkgs.fetchFromGitHub {
        # owner = "yt-dlp";
        # repo = "ejs";
        # tag = "0.8.0";
        #   hash = "sha256-+tOA9sPk0BGJHFQCoAC8y5Bz3UcjgIPDQ8WDPkRlW5k=";
        # };
        #}))
        # Transitive dependencies often required explicitly if build fails:
        python.pkgs.certifi
        python.pkgs.idna
        python.pkgs.charset-normalizer
        python.pkgs.urllib3
        python.pkgs.six
        python.pkgs.numpy
        python.pkgs.packaging
      ];

      format = "pyproject";
      #doCheck = false;

      meta = with pkgs.lib; {
        description = "Download stuff like Hydrus does.";
        homepage = "https://gitgud.io/thatfuckingbird/hydownloader";
        mainProgram = "hydl";
        license = licenses.agpl3Plus;
      };
    };
  in {
    packages.hydownloader = hydownloader;
  };
}

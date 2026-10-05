{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.ai = {pkgs, ...}: {
    
      imports = [
      inputs.pi.nixosModules.default
    ];
    programs.pi.coding-agent = {
    enable = true;
      # rules = ''Be concise.'';
      # skills = [ ./skills/my-skill ];
      # extensions = [ ./extensions/my-extension.ts ];
      # themes = [ ./themes/catppuccin-mocha.json ];
      # promptTemplates = [ ./prompts ];
      # models = ./models.json;
      # settings = {
      #   model = "gpt-5";
      # };
      jail.enable = true;
      jail.permissions = combinators: with combinators; [
        network
        mount-cwd

        # 1. Make the host's system binaries available in the jail's PATH
        (add-path "/run/current-system/sw/bin")

        # 2. Add the specific packages you need (this also adds their /bin to PATH)
        /*(add-pkg-deps [
          pkgs.jq
          pkgs.gnumake
          pkgs.python3
          pkgs.coreutils
          pkgs.curl
        ])*/

        # 3. Bind specific files read-only
        (try-readonly (noescape "~/.gitconfig"))
        (readonly "/etc/nix")
        (readonly "/etc/static")
        (readonly "/nix")


        # 4. Bind the host's /bin directory read-only (if you want the actual binaries)
        #    Note: This is often unnecessary if you use add-path, but included for completeness.
        (readonly "/run/current-system/sw/bin")
      ];
      # extraArgs = [ "--provider" "openai" "--model" "gpt-5" ];
      # environment.PI_CODING_AGENT_DIR.value = "/path/to/pi-agent";
      # environment.OPENAI_API_KEY.file = config.sops.secrets.openai-api-key.path;
    };


    services.comfyui = {
      enable = true;
      gpuSupport = "cuda";
      cudaCapabilities = ["8.9"];
      enableManager = true;
      port = 8188;
      listenAddress = "127.0.0.1";
      dataDir = "/home/mortal/.local/share/ComfyUI";
      user = "mortal";
      group = "users";
      createUser = false;
      openFirewall = false;
      customNodes = {
        comfyui-image-saver = pkgs.fetchFromGitHub {
          owner = "alexopus";
          repo = "ComfyUI-Image-Saver";
          rev = "v1.24.1";
          hash = "sha256-mxz69YLYfXdcGCMR7i/otWysuGDDlQ6U3CXjy5i5W04=";
        };
        comfyui-lora-manager = pkgs.fetchFromGitHub {
          owner = "willmiao";
          repo = "ComfyUI-Lora-Manager";
          rev = "v1.2.1";
          hash = "sha256-M9dCClZbF3Q/4OrY+962EATjOqbNCDYv4oV0Su5feV8=";
        };
      };
      extraPythonPackages = ps:
        with ps; [
          natsort
        ];
      # extraArgs = [ "--lowvram" ];
      # environment = { };
    };

    environment.systemPackages =
      (with pkgs; [
        lmstudio
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.llama-cpp-optimized
      ])
      ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        dsh
        # pi
      ]);
  };
}

{inputs, ...}: {
  flake.homeModules.zen-browser = {pkgs, ...}: {
    imports = [
      inputs.zen-browser-flake.homeModules.default
      inputs.self.homeModules."zen-browser@extensions"
      inputs.self.homeModules."zen-browser@tabs"
      # or inputs.zen-browser.homeModules.twilight
      # or inputs.zen-browser.homeModules.twilight-official
    ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      policies = {
        default.settings = {
          "zen.workspaces.continue-where-left-off" = true;
          "zen.view.compact.hide-tabbar" = true;
          #"zen.urlbar.behavior" = "float";
          "zen.welcome-screen.seen" = true;
        };

        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
    };

    /*
      xdg.desktopEntries."zen-beta" = {
      name = "Zen Browser"; # fixes the menu label
    };
    */
  };
  flake.homeModules."zen-browser@extensions" = {pkgs, ...}: let
    mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      installation_mode = "force_installed";
    });
  in {
    programs.zen-browser.policies.ExtensionSettings = mkExtensionSettings {
      "{e4b27483-2e73-4762-b2ec-8d988a143a40}" = "asbplayer-language-learning";
      "addon@darkreader.org" = "darkreader";
      "foxyproxy@eric.h.jung" = "foxyproxy-standard";
      "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}" = "greasemonkey";
      "sponsorBlocker@ajay.app" = "sponsorblock";
      "uBlock0@raymondhill.net" = "ublock-origin";
      "{6b733b82-9261-47ee-a595-2dda294a4d08}" = "yomitan";
    };
  };

  flake.homeModules."zen-browser@tabs" = {...}: {
    programs.zen-browser.profiles.default = let
      pins = {
        "YouTube" = {
          id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890";
          url = "https://youtube.com";
          position = 1;
          isEssential = true;
        };
        "Deepseek Chat" = {
          id = "b2c3d4e5-f6a7-8901-bcde-f12345678901";
          url = "https://chat.deepseek.com";
          position = 2;
          isEssential = true;
        };
        "Qwen AI" = {
          id = "c3d4e5f6-a7b8-9012-cdef-123456789012";
          url = "https://chat.qwen.ai";
          position = 3;
          isEssential = true;
        };
        "VK" = {
          id = "d4e5f6a7-b8c9-0123-def0-234567890123";
          url = "https://vk.com";
          position = 4;
          isEssential = true;
        };
        "Reddit" = {
          id = "e5f6a7b8-c9d0-1234-ef01-345678901234";
          url = "https://reddit.com";
          position = 5;
          isEssential = true;
        };
        "Perplexity" = {
          id = "f6a7b8c9-d0e1-2345-f012-456789012345";
          url = "https://perplexity.ai";
          position = 6;
          isEssential = true;
        };
        "Hermes Dashboard" = {
          id = "a7b8c9d0-e1f2-3456-0123-567890123456";
          url = "http://192.168.0.116:9119";
          position = 7;
          isEssential = true;
        };
      };
    in {
      inherit pins;
      pinsForce = true;
      pinsForceAction = "demote"; # delete any undeclared pinned tabs
    };
  };
}

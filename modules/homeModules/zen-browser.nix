{inputs, ...}: {
  flake.homeModules.zen-browser = {pkgs, ...}: {
    imports = [
      inputs.zen-browser.homeModules.default
      # or inputs.zen-browser.homeModules.twilight
      # or inputs.zen-browser.homeModules.twilight-official
    ];

    programs.zen-browser = {
      enable = true;
      setAsDefaultBrowser = true;

      policies = {
        default.settings = {
          /**
          use double quotes!
          */
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
  };
  flake.homeModules."zen-browser@extensions" = let                                                                                           
          mkExtensionSettings = builtins.mapAttrs (_: pluginId: {                                                                                
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";                                          
            installation_mode = "force_installed";                                                                                               
          });                                                                                                                                    
        in {                                                                                                                                     
          programs.zen-browser.policies.ExtensionSettings = mkExtensionSettings {                                                                
            "{e4b27483-2e73-4762-b2ec-8d988a143a40}" = "asbplayer-language-learning";                                                            
            "@addon@darkreader.org"                 = "darkreader";                                                                              
            "foxyproxy@eric.h.jung"                = "foxyproxy-standard";                                                                       
            "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}" = "greasemonkey";                                                                           
            "sponsorBlocker@ajay.app"              = "sponsorblock";                                                                             
            "uBlock0@raymondhill.net"              = "ublock-origin";                                                                            
            "{6b733b82-9261-47ee-a595-2dda294a4d08}" = "yomitar";                                                                                
          };                                                                                                                                     
        };       
}

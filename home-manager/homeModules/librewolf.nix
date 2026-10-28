{inputs, ...}: {
  flake.homeModules.librewolf = {pkgs, ...}: {
    imports = [
      inputs.self.homeModules."librewolf@extensions"
    ];

    programs.librewolf = {
      configPath = ".config/librewolf";
      enable = true;

      profiles.default.settings = {
        "browser.toolbars.bookmarks.visibility" = "newtab";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        #"mousewheel.default.delta_multiplier_y" = 150;
        "apz.gtk.kinetic_scroll.delta_mode" = 2;
        "apz.gtk.pangesture.delta_mode" = 2;
        "apz.gtk.kinetic_scroll.pixel_delta_mode_multiplier" = 20;
        "apz.gtk.pangesture.pixel_delta_mode_multiplier" = 20;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.dmabuf.force-enabled" = 1;
      };

      policies = {
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
  flake.homeModules."librewolf@extensions" = {pkgs, ...}: let
    mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      installation_mode = "force_installed";
    });
  in {
    programs.librewolf.policies.ExtensionSettings = mkExtensionSettings {
      "addon@darkreader.org" = "darkreader";
      "foxyproxy@eric.h.jung" = "foxyproxy-standard";
      "{e4a8a97b-f2ed-450b-b12d-ee082ba24781}" = "greasemonkey";
      "sponsorBlocker@ajay.app" = "sponsorblock";
      "{6b733b82-9261-47ee-a595-2dda294a4d08}" = "yomitan";
      "pywalfox@frewacom.org" = "Pywalfox";
    };
  };
}

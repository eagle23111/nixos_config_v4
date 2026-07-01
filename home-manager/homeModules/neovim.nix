{inputs, ...}: {
  flake.homeModules.neovim = {pkgs, ...}: {
    imports = [
      inputs.nixvim.homeModules.default
    ];
    stylix.targets.nixvim.enable = true;
    programs.nixvim = {
      enable = true;

      plugins.lsp = {
        enable = true;

        servers = {
          ts_ls.enable = true;

          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          rust_analyzer = {
            enable = true;
            installCargo = true;
            installRustc = true;
          };

          pyright.enable = true;
        };
      };

      plugins.cmp = {
        enable = true;
        autoEnableSources = true;

        settings.sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];

        settings.mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expandable() then
                luasnip.expand()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif check_backspace() then
                fallback()
              else
                fallback()
              end
            end, { "i", "s" })
          '';
        };
      };

      keymaps = [
        {
          action = "<cmd>Telescope live_grep<CR>";
          key = "<leader>g";
        }
      ];

      plugins.treesitter.enable = true;
      plugins.oil.enable = true;
      plugins.telescope.enable = true;
      plugins.luasnip.enable = true;
    };
  };
}

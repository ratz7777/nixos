{ config, pkgs, ... }:
{
  programs.nixvim = {
    enable = true;

    # --- Appearance ---
    colorschemes.rose-pine = {
      enable = true;
      settings = {
        variant = "main"; # Or "moon" for a slightly cooler reddish-purple
        dark_variant = "main";
        styles = {
          italic = true;
          bold = true;
        };
      };
    };

    opts = {
      number = true;         # Show line numbers
      relativenumber = true; # Relative line numbers for easier jumping
      shiftwidth = 2;        # Tab width
      expandtab = false;      # Use spaces instead of tabs
      termguicolors = true;  # Enable 24-bit RGB color
    };

    # --- Plugins ---
    plugins = {
      # Status line at the bottom
      lualine.enable = true;

      # File tree
      neo-tree.enable = true;

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };

      # LSP Configuration
      lsp = {
        enable = true;
        servers = {
          # C/C++ Support
          clangd.enable = true;

          # Optional: Nix support (useful since you're editing nix files!)
          nil_ls.enable = true;
        };
        keymaps.lspBuf = {
          "gd" = "definition";
          "K" = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        settings = {
          autoEnableSources = true;
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
        };
      };
    };

    # Set the leader key to space
    globals.mapleader = " ";
  };
}

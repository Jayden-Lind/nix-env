# Neovim as the main IDE: LazyVim on top of Nix-provided tooling.
#
# Split of responsibilities:
#   - Nix (this file, pinned by flake.lock): neovim itself plus every
#     language server, formatter, linter and debug adapter, so nothing is
#     downloaded by mason.nvim at runtime.
#   - lazy.nvim (./config, pinned by lazy-lock.json): the plugins
#     themselves, including LazyVim and its extras.
#
# ./config is what ends up at ~/.config/nvim — see `nixEnv.neovim.checkout`
# for how it's linked.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nixEnv.neovim;

  # nvim-treesitter builds parsers with the tree-sitter CLI, which compiles
  # them with $CC. Point that at Nix's compiler so parser builds don't
  # depend on Xcode CLT / base-devel (on a Mac without CLT /usr/bin/cc is
  # just an "install developer tools" stub).
  treeSitter = pkgs.writeShellScriptBin "tree-sitter" ''
    export CC=${pkgs.stdenv.cc}/bin/cc
    exec ${lib.getExe pkgs.tree-sitter} "$@"
  '';

  # gotools ships ~60 binaries with generic names (bundle, play, stress…);
  # only goimports is wanted.
  goimports = pkgs.runCommand "goimports" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.gotools}/bin/goimports $out/bin/goimports
  '';

  # LazyVim's TypeScript debug config calls the adapter by its mason name.
  jsDebugAdapter = pkgs.writeShellScriptBin "js-debug-adapter" ''
    exec ${pkgs.vscode-js-debug}/bin/js-debug "$@"
  '';
in
{
  options.nixEnv.neovim.checkout = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "/home/jayden/git/nix-env";
    description = ''
      Absolute path to a local clone of this repo. When set, ~/.config/nvim
      links straight into the clone's modules/neovim/config, so Lua edits
      apply without a switch and lazy.nvim writes lazy-lock.json back into
      git. When null (e.g. the work laptop consuming the flake), the config
      is a read-only copy from the Nix store.
    '';
  };

  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # No LazyVim plugin needs the remote-plugin hosts
      withNodeJs = false;
      withPython3 = false;
      withRuby = false;
      # The wrapper's generated init (the provider switches above) would
      # otherwise be written to ~/.config/nvim/init.lua, which is ./config's
      # — pass it via --cmd instead.
      sideloadInitLua = true;

      # Only on nvim's PATH (appended, so a project's own toolchain from a
      # devshell/direnv still wins). mason.nvim is disabled in
      # config/lua/plugins/nix.lua — add new tools here instead.
      extraPackages = with pkgs; [
        # Treesitter parser builds
        treeSitter
        stdenv.cc

        # Lua (the Neovim config itself)
        lua-language-server
        stylua

        # Go
        gopls
        goimports
        gofumpt
        golangci-lint
        delve

        # TypeScript / JavaScript (+ JSON, HTML, CSS, ESLint servers)
        vtsls
        vscode-langservers-extracted
        prettier
        jsDebugAdapter

        # Bash / shell
        bash-language-server
        shellcheck
        shfmt

        # Ansible
        ansible-language-server
        ansible-lint

        # Terraform (terraform fmt/validate use the terraform binary from
        # modules/packages.nix)
        terraform-ls

        # Nix
        nil
        nixfmt
        statix

        # YAML, Helm, Docker
        yaml-language-server
        helm-ls
        dockerfile-language-server
        docker-compose-language-service
        hadolint

        # Markdown
        marksman
        markdownlint-cli2
        markdown-toc

        # Python
        pyright
        ruff
        python3Packages.debugpy

        # TOML
        taplo
      ];
    };

    home.packages = with pkgs; [
      lazygit # <leader>gg; also handy standalone
      # LazyVim's UI assumes a Nerd Font — set it as the terminal font
      nerd-fonts.jetbrains-mono
    ];

    # Lets fontconfig-based terminals on Linux find the font above
    # (macOS picks it up from ~/Library/Fonts/HomeManager)
    fonts.fontconfig.enable = true;

    xdg.configFile."nvim".source =
      if cfg.checkout != null then
        config.lib.file.mkOutOfStoreSymlink "${cfg.checkout}/modules/neovim/config"
      else
        ./config;

    # An out-of-store link can't be checked at build time, so catch a wrong
    # checkout path at switch time rather than with a config-less nvim.
    home.activation.checkNeovimCheckout = lib.mkIf (cfg.checkout != null) (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [[ ! -f ${lib.escapeShellArg "${cfg.checkout}/modules/neovim/config/init.lua"} ]]; then
          warnEcho "nixEnv.neovim.checkout: no LazyVim config under ${cfg.checkout}/modules/neovim/config,"
          warnEcho "so ~/.config/nvim is a dangling link. Clone this repo there or fix the path."
        fi
      ''
    );
  };
}

# Template for the work laptop. Copy this file to the work machine
# (e.g. ~/work-env/flake.nix), fill in the CHANGE-ME values, then:
#
#   nix run home-manager -- switch --flake ~/work-env#work -b backup
#
# This file stays on the work laptop (or in a work-private repo) — it is
# never committed to shell-env. It pulls the shared packages + shell
# setup from shell-env and layers work-only config on top.
#
# Shell history stays separate automatically: atuin only syncs where you
# run `atuin login` — don't log in with your personal account here.
{
  description = "Work laptop shell environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Needs access to the shell-env repo from the work machine.
    # Alternatively clone it and use: url = "git+file:///path/to/shell-env"
    shell-env = {
      url = "github:Jayden-Lind/shell-env";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, shell-env, ... }:
    let
      system = "aarch64-darwin"; # CHANGE-ME: x86_64-linux / aarch64-darwin / x86_64-darwin
      username = "CHANGE-ME";
      homeDirectory = "/Users/CHANGE-ME"; # /home/<user> on Linux
    in
    {
      homeConfigurations.work = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true; # terraform, claude-code
        };
        modules = [
          shell-env.homeManagerModules.default
          {
            home = { inherit username homeDirectory; };
            home.stateVersion = "25.05";
            programs.home-manager.enable = true;

            programs.git = {
              enable = true;
              settings = {
                user.name = "Jayden Lind";
                user.email = "CHANGE-ME@work.example"; # work identity
                core.autocrlf = "input";
                init.defaultBranch = "main";
              };
            };

            # Work-only packages and env go here:
            # home.packages = with pkgs; [ awscli2 azure-cli ];
            # home.sessionVariables.KUBECONFIG = "...";
          }
        ];
      };
    };
}

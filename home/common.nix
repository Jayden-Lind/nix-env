{ pkgs, config, ... }:

{
  imports = [
    ./packages.nix
    ./zsh.nix
    ./git.nix
  ];

  # Let home-manager manage itself so the `home-manager` command is
  # available after the first `nix run home-manager -- switch`.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
    KUBECONFIG = "${config.home.homeDirectory}/kubeconfig.conf";
    TALOSCONFIG = "${config.home.homeDirectory}/git/LINDS-Terraform/proxmox/talosconfig";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Do not change this after the first activation — it pins state
  # migration behaviour, not the nixpkgs version.
  home.stateVersion = "25.05";
}

{ pkgs, config, ... }:

{
  # Personal profile: the shared core plus things that must never reach
  # the work laptop (git identity, sops secrets, homelab env vars).
  imports = [
    ../modules
    ./git.nix
    ./secrets.nix
  ];

  # Let home-manager manage itself so the `home-manager` command is
  # available after the first `nix run home-manager -- switch`.
  programs.home-manager.enable = true;

  # Homelab-only tooling. Lives here rather than modules/packages.nix so it
  # never reaches the work laptop.
  home.packages = with pkgs; [
    # Secrets backend for the cluster (external-secrets reads linds-keyvault
    # from it). Unfree (BUSL) — covered by allowUnfree in flake.nix.
    vault
  ];

  home.sessionVariables = {
    KUBECONFIG = "${config.home.homeDirectory}/KUBECONFIG";
    TALOSCONFIG = "${config.home.homeDirectory}/git/LINDS-Terraform/proxmox/talosconfig";
    # Vault's cert is signed by linds-CA, which these machines already trust.
    VAULT_ADDR = "https://vault.linds.com.au";
  };

  # ~/.config/nvim links into this checkout so LazyVim config edits and
  # lazy-lock.json updates land straight in git (EDITOR=nvim comes from
  # modules/neovim).
  nixEnv.neovim.checkout = "${config.home.homeDirectory}/git/nix-env";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  # Do not change this after the first activation — it pins state
  # migration behaviour, not the nixpkgs version.
  home.stateVersion = "25.05";
}

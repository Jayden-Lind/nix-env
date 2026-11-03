{ lib, pkgs, pkgs-master ? pkgs, ... }:

{
  home.packages = with pkgs; [
    # Kubernetes
    kubectl
    kubernetes-helm
    k9s
    talosctl
    kustomize
    kubectx # kubectx + kubens

    # Infrastructure as code
    terraform
    packer
    ansible

    # Dev tooling (editor: Neovim, see ./neovim)
    gh
    go
    nodejs # runtime for TypeScript projects and their debugger

    # Secrets tooling (used by home/secrets.nix on personal machines)
    sops
    age

    # CLI utilities
    ripgrep
    fd
    jq
    yq-go
    nmap
    rsync
    wget
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # macOS only. On CachyOS the pacman builds must win on PATH: Nix python3
    # can't load system libraries (gi, libz, libcuda), and Nix btop can't
    # load NVML, so it never sees the RTX 3090.
    pkgs.python3
    pkgs.btop
  ] ++ (with pkgs-master; [
    # AI tooling — pulled from nixpkgs master for faster-moving releases
    claude-code
  ]);

  # fzf keybindings (Ctrl-T file picker, Alt-C cd; atuin owns Ctrl-R)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    historyWidget.zsh.command = ""; # Ctrl-R belongs to atuin
  };

  # Searchable shell history; syncs E2E-encrypted between machines that
  # log into the same account (`atuin register` once, `atuin login`
  # elsewhere). Machines that never log in keep local-only history.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # Up-arrow stays with history-substring-search; atuin keeps Ctrl-R
    flags = [ "--disable-up-arrow" ];
    settings = {
      # Don't hijack `?` for atuin's AI assistant; flip to true to try it
      ai.enabled = false;
    };
  };
}

{ pkgs, ... }:

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

    # AI tooling
    claude-code

    # Dev tooling
    gh
    go
    python3
    vim

    # Secrets tooling (used by home/secrets.nix on personal machines)
    sops
    age

    # CLI utilities
    ripgrep
    fd
    jq
    yq-go
    btop
    nmap
    rsync
    wget
  ];

  # fzf keybindings (Ctrl-T file picker, Alt-C cd; atuin owns Ctrl-R)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
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

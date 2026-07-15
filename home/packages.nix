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

  # fzf with shell keybindings (Ctrl-R history, Ctrl-T files, Alt-C cd)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}

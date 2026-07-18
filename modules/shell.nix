{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # compinit with the fpath already including every Nix package's
    # bundled completions (share/zsh/site-functions), so kubectl, helm,
    # k9s, talosctl, gh, etc. all complete out of the box.
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Up/Down arrows search history filtered by what's already typed
    historySubstringSearch.enable = true;

    history = {
      size = 100000;
      save = 100000;
      share = true;
      append = true;
      ignoreAllDups = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      # Plugins add aliases (kgp, tf, ...) and completions for tools
      # that don't ship zsh completions themselves (terraform, ansible).
      plugins = [
        "git"
        "sudo" # ESC ESC prepends sudo to the current command
        "kubectl"
        "helm"
        "terraform"
        "ansible"
        "golang" # go ships no completions upstream
        "extract" # `extract <archive>` unpacks any format
      ];
    };

    initContent = ''
      setopt autocd
      setopt extendedglob
      setopt globdots
      setopt interactivecomments

      # Menu-style completion
      zmodload zsh/complist
      setopt auto_menu complete_in_word
      zstyle ':completion:*' menu select

      # Emacs keybindings
      bindkey -e

      # talosctl ships completions via `talosctl completion`; the Nix
      # package also installs them, but this keeps them current with
      # the installed version.
      command -v talosctl >/dev/null && source <(talosctl completion zsh)
    '';
  };
}

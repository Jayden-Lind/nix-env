# shell-env

Portable shell environment managed with [Nix](https://nixos.org) +
[home-manager](https://github.com/nix-community/home-manager). One repo gives an
identical toolset and zsh configuration (aliases, completions, keybindings,
history behaviour) on:

| Host | Config name | System |
|---|---|---|
| CachyOS desktop | `jayden@desktop` | `x86_64-linux` |
| M1 MacBook | `jayden@macbook` | `aarch64-darwin` |

## What's included

**Packages** (see [`home/packages.nix`](home/packages.nix)):
kubectl, helm, k9s, talosctl, kustomize, kubectx/kubens, terraform, packer,
ansible, claude-code, gh, go, python3, vim, fzf, ripgrep, fd, jq, yq, btop,
nmap, rsync, wget.

**Shell** (see [`home/zsh.nix`](home/zsh.nix)):
zsh with oh-my-zsh (robbyrussell theme), autosuggestions, syntax highlighting,
fzf keybindings (`Ctrl-R` history search, `Ctrl-T` file picker, `Alt-C` cd),
menu-select completion, shared 100k-line history, and tab completion for every
tool above.

**Git** (see [`home/git.nix`](home/git.nix)): user identity, `autocrlf=input`,
`init.defaultBranch=main`.

Completions work two ways: Nix packages install their zsh completions into the
profile's `share/zsh/site-functions`, which home-manager puts on `fpath`
automatically; tools that don't ship them (terraform, ansible) are covered by
oh-my-zsh plugins.

## First-time setup

### 1. Install Nix

Same command on both Linux and macOS — the
[Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
enables flakes by default and survives macOS upgrades:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Open a new terminal afterwards so `nix` is on your `PATH`.

### 2. Clone and activate

```sh
git clone <this-repo-url> ~/git/shell-env
cd ~/git/shell-env

# Desktop:
nix run home-manager -- switch --flake .#jayden@desktop -b backup

# MacBook:
nix run home-manager -- switch --flake .#jayden@macbook -b backup
```

`-b backup` moves any existing dotfiles that would be overwritten (e.g. your
current `~/.zshrc`) to `<file>.backup` instead of failing. Only needed the
first time.

After the first switch, home-manager itself is installed, so future
activations are just:

```sh
home-manager switch --flake ~/git/shell-env#jayden@desktop
```

### 3. Log out / open a new shell

Session variables (`EDITOR`, `KUBECONFIG`, `TALOSCONFIG`, `PATH`) are set by
`~/.zshenv`, which home-manager now manages — start a fresh shell to pick
them up.

> **Note (desktop):** your previous zsh setup (oh-my-zsh under `~/.oh-my-zsh`,
> CachyOS zsh config) is replaced by the generated `~/.zshrc`. The old file is
> kept as `~/.zshrc.backup`. Once you're happy, the pacman-installed
> duplicates (k9s, terraform, ansible, …) can be removed so only the Nix
> versions are on `PATH`.

> **Note (MacBook):** if your macOS username isn't `jayden`, change
> `username`/`homeDirectory` for `jayden@macbook` in [`flake.nix`](flake.nix).

## Day-to-day usage

### Add a tool

Search for the package name, add it to `home/packages.nix`, switch:

```sh
nix search nixpkgs opentofu
vim home/packages.nix
home-manager switch --flake .#jayden@desktop
git commit -am "Add opentofu"
```

Machine-specific packages go in `hosts/desktop.nix` or `hosts/macbook.nix`
instead.

### Update all tools

```sh
nix flake update            # bumps flake.lock to latest nixpkgs
home-manager switch --flake .#jayden@desktop
git commit -am "Update flake inputs"
```

Because `flake.lock` is committed, both machines get **exactly** the same
package versions — run the same `switch` on the other machine after pulling.

### Roll back

```sh
home-manager generations           # list previous generations
/nix/store/...-generation/activate # run the activate script of an older one
```

Or just `git revert` the change and `switch` again.

## Repo layout

```
flake.nix           # inputs, one homeConfiguration per machine
flake.lock          # pinned versions (commit this!)
home/
  common.nix        # entry point: env vars, PATH, stateVersion
  packages.nix      # the tool list (shared across machines)
  zsh.nix           # zsh + oh-my-zsh + completions
  git.nix           # git identity and defaults
hosts/
  desktop.nix       # CachyOS-only overrides
  macbook.nix       # macOS-only overrides
```

## Troubleshooting

- **`experimental-features` error** — your Nix install doesn't have flakes
  enabled. Add `experimental-features = nix-command flakes` to
  `~/.config/nix/nix.conf` (the Determinate installer does this for you).
- **"unfree package" refused** — should not happen (the flake sets
  `allowUnfree = true` for terraform/claude-code), but if you build the
  modules outside this flake you'll need `NIXPKGS_ALLOW_UNFREE=1 --impure`.
- **Completions missing for a new tool** — start a new shell first; if still
  missing, the package may not ship zsh completions — add a
  `source <(tool completion zsh)` line in `home/zsh.nix`.
- **Wrong tool version on `PATH`** — `~/.nix-profile/bin` must come before
  `/usr/bin`; check with `which -a kubectl`. Remove the distro/homebrew copy.

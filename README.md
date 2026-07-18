# shell-env

Portable shell environment managed with [Nix](https://nixos.org) +
[home-manager](https://github.com/nix-community/home-manager). One repo gives an
identical toolset and zsh configuration (aliases, completions, keybindings,
history behaviour) on:

| Host | Config name | System |
|---|---|---|
| CachyOS desktop | `jayden@desktop` | `x86_64-linux` |
| M1 MacBook | `jayden@macbook` | `aarch64-darwin` |
| Work MacBook | `work` (own flake, see [Work laptop](#work-laptop-consume-as-a-module)) | `aarch64-darwin` |

## How it's layered

The config is three layers, so the work laptop can share the shell experience
without sharing anything personal:

| Layer | Contents | Desktop | MacBook | Work |
|---|---|:-:|:-:|:-:|
| `modules/` (shareable core) | packages + zsh/fzf/atuin setup | ✅ | ✅ | ✅ |
| `home/` (personal) | git identity, sops secrets, homelab env vars | ✅ | ✅ | ❌ |
| `hosts/*.nix` / work's own flake | machine-specific packages & overrides | own | own | own |

**Where does a new package/setting go?**

- Every machine including work → `modules/packages.nix` (or `modules/shell.nix`
  for shell behaviour)
- Both personal machines, but never work → `home/common.nix` (or `home/git.nix`
  / `home/secrets.nix`)
- One machine only → `hosts/desktop.nix`, `hosts/macbook.nix`, or the work
  laptop's local flake

## What's included

**Packages** (see [`modules/packages.nix`](modules/packages.nix)):
kubectl, helm, k9s, talosctl, kustomize, kubectx/kubens, terraform, packer,
ansible, claude-code, gh, go, python3, vim, fzf, ripgrep, fd, jq, yq, btop,
nmap, rsync, wget.

**Shell** (see [`modules/shell.nix`](modules/shell.nix)):
zsh with oh-my-zsh (robbyrussell theme), autosuggestions, syntax highlighting,
atuin (`Ctrl-R` searchable history, synced encrypted between machines — run
`atuin register`/`atuin login` once per machine), history-substring-search
(Up-arrow filters by what you've typed), fzf (`Ctrl-T` file picker, `Alt-C`
cd), `extract <archive>` for any format, ESC-ESC to prepend sudo, menu-select
completion, and tab completion for every tool above.

**Git** (see [`home/git.nix`](home/git.nix)): user identity, `autocrlf=input`,
`init.defaultBranch=main`.

### Completions

Completions are automatic for any package that ships them: Nix installs each
package's zsh completions into the profile's `share/zsh/site-functions`, which
home-manager puts on `fpath` before running `compinit` — nothing to enable
per-tool. Tools that don't ship completion files (terraform, ansible, go) are
covered by oh-my-zsh plugins in `modules/shell.nix`.

After adding packages, check coverage with:

```sh
zsh scripts/completion-audit.zsh
```

If something you care about shows `MISS`, plug it with (in order of
preference): an oh-my-zsh plugin in `modules/shell.nix`; or, for tools with a
`<tool> completion zsh` subcommand, a
`command -v <tool> >/dev/null && source <(<tool> completion zsh)` line in
`initContent` in `modules/shell.nix`. Some tools (btop, age, claude) simply have no completions —
a `MISS` there is expected.

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

Search for the package name, add it to `modules/packages.nix`, switch:

```sh
nix search nixpkgs opentofu
vim modules/packages.nix
home-manager switch --flake .#jayden@desktop
git commit -am "Add opentofu"
```

That reaches all machines, including work (next time it updates). For
personal-only or machine-specific tools, pick the right layer — see
[How it's layered](#how-its-layered).

### Update all tools

```sh
nix flake update            # bumps flake.lock to latest nixpkgs
home-manager switch --flake .#jayden@desktop
git commit -am "Update flake inputs"
```

Because `flake.lock` is committed, both machines get **exactly** the same
package versions — run the same `switch` on the other machine after pulling.

### Secrets (encrypted in git)

Sensitive files live in [`secrets/`](secrets/), encrypted with
[sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age)
— safe to commit and push. At activation, [sops-nix](https://github.com/Mic92/sops-nix)
decrypts them into tmpfs (`/run/user/…`, mode `0400`, never on disk) and
symlinks them into place. `~/kubeconfig.conf` is managed this way.

The **age private key** at `~/.config/sops/age/keys.txt` is the one thing NOT
in git. Copy it to each machine once:

```sh
# from the desktop
scp -p ~/.config/sops/age/keys.txt mac:.config/sops/age/keys.txt
```

⚠️ **Back this key up somewhere safe** (password manager). Anyone with it can
read the secrets; without it the secrets are unrecoverable.

**Add a new secret** (e.g. talosconfig):

```sh
cd ~/git/shell-env
sops encrypt --filename-override secrets/talosconfig \
  --input-type binary --output-type binary ~/path/to/talosconfig > secrets/talosconfig
```

then declare it in [`home/secrets.nix`](home/secrets.nix):

```nix
secrets.talosconfig = {
  sopsFile = ../secrets/talosconfig;
  format = "binary";
  path = "${config.home.homeDirectory}/.talos/config";
};
```

`git add` it (flakes only see tracked files), then `home-manager switch`.

**Edit a secret in place:** `sops edit secrets/kubeconfig` (decrypts into
`$EDITOR`, re-encrypts on save).

**Never** redirect plaintext into `secrets/` without going through `sops` —
review `git diff --cached secrets/` before committing if unsure.

### Roll back

```sh
home-manager generations           # list previous generations
/nix/store/...-generation/activate # run the activate script of an older one
```

Or just `git revert` the change and `switch` again.

## Repo layout

```
flake.nix           # inputs, homeConfigurations, homeManagerModules export
flake.lock          # pinned versions (commit this!)
modules/            # SHAREABLE core — exported as homeManagerModules.default
  packages.nix      # the tool list
  shell.nix         # zsh + oh-my-zsh + fzf + atuin + completions
home/               # PERSONAL profile (desktop + macbook only)
  common.nix        # modules/ + personal env vars, PATH, stateVersion
  git.nix           # personal git identity
  secrets.nix       # sops-encrypted secrets wiring
hosts/
  desktop.nix       # CachyOS-only overrides
  macbook.nix       # macOS-only overrides
examples/work/      # template flake for the work laptop (see below)
scripts/            # completion-audit.zsh
secrets/            # sops-encrypted files (safe in git)
```

## Work laptop (consume as a module)

The work laptop gets the **same packages and shell setup without any personal
config** — no git identity, no sops secrets/age key, no homelab env vars, and
no shared history (atuin only syncs where you run `atuin login`; use a
different account or none at work).

It works by consuming this repo as a flake input rather than cloning-and-
activating it: copy [`examples/work/flake.nix`](examples/work/flake.nix) to
the work machine (e.g. `~/work-env/flake.nix`), fill in the `CHANGE-ME`
values (system, username, work git email), then:

```sh
nix run home-manager -- switch --flake ~/work-env#work -b backup
```

That local flake is where work-only packages/env vars go; it never gets
committed to this repo (keep it local or in a work-private repo). Updates
flow one way: push changes here, then on the work laptop
`nix flake update && home-manager switch --flake ~/work-env#work`.

> The work machine needs read access to this repo on GitHub. If it can't
> reach it, clone the repo manually and set the input to
> `git+file:///path/to/shell-env`.

## Troubleshooting

- **`experimental-features` error** — your Nix install doesn't have flakes
  enabled. Add `experimental-features = nix-command flakes` to
  `~/.config/nix/nix.conf` (the Determinate installer does this for you).
- **"unfree package" refused** — should not happen (the flake sets
  `allowUnfree = true` for terraform/claude-code), but if you build the
  modules outside this flake you'll need `NIXPKGS_ALLOW_UNFREE=1 --impure`.
- **Completions missing for a new tool** — start a new shell first; if still
  missing, the package may not ship zsh completions — add a
  `source <(tool completion zsh)` line in `modules/shell.nix`.
- **Wrong tool version on `PATH`** — `~/.nix-profile/bin` must come before
  `/usr/bin`; check with `which -a kubectl`. Remove the distro/homebrew copy.

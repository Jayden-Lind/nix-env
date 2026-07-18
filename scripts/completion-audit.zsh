#!/usr/bin/env zsh
# Reports which installed binaries have zsh tab completion registered.
# Run after adding packages: zsh scripts/completion-audit.zsh
# MISS is only a problem for tools you actually tab-complete — see the
# "Completions" section in the README for how to plug a gap.
env -u ZDOTDIR zsh -ic '
for bin in ~/.nix-profile/bin/*(N:t); do
  [[ $bin == .* ]] && continue  # skip nix wrapper internals
  if (( ${+_comps[$bin]} )); then echo "OK   $bin"; else echo "MISS $bin"; fi
done' 2>/dev/null | sort -k2 | sort -s -k1,1r

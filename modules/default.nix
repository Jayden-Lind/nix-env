# Shareable core: packages + shell setup, no personal config.
# Exported from the flake as `homeManagerModules.default` so other
# machines (e.g. the work laptop) can consume it as an input.
{ ... }:

{
  imports = [
    ./packages.nix
    ./shell.nix
  ];
}

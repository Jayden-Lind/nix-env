{
  description = "Jayden's portable shell environment — CachyOS desktop + M1 MacBook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }:
    let
      mkHome = { system, homeDirectory, username ? "jayden", extraModules ? [ ] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            # terraform (BSL licence) and claude-code are marked unfree
            config.allowUnfree = true;
          };
          modules = [
            sops-nix.homeManagerModules.sops
            ./home/common.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ] ++ extraModules;
        };
    in
    {
      # Shared core (packages + shell, no personal config) for other
      # machines to consume — see examples/work/flake.nix and README.
      homeManagerModules.default = ./modules;

      homeConfigurations = {
        # CachyOS desktop (x86_64 Linux)
        "jayden@desktop" = mkHome {
          system = "x86_64-linux";
          homeDirectory = "/home/jayden";
          extraModules = [ ./hosts/desktop.nix ];
        };

        # M1 MacBook (Apple Silicon)
        "jayden@macbook" = mkHome {
          system = "aarch64-darwin";
          homeDirectory = "/Users/jayden";
          extraModules = [ ./hosts/macbook.nix ];
        };
      };
    };
}

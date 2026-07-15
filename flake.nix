{
  description = "Jayden's portable shell environment — CachyOS desktop + M1 MacBook";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      mkHome = { system, homeDirectory, username ? "jayden", extraModules ? [ ] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            # terraform (BSL licence) and claude-code are marked unfree
            config.allowUnfree = true;
          };
          modules = [
            ./home/common.nix
            {
              home.username = username;
              home.homeDirectory = homeDirectory;
            }
          ] ++ extraModules;
        };
    in
    {
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

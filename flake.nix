{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    llm-agents.url = "github:numtide/llm-agents.nix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, llm-agents, disko, ... }@inputs:
let
  mkNixos = name: ipv6Address:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; hostName = name; ipv6Address = ipv6Address; };
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
        ./disko.nix
      ];
    };
in {
  nixosConfigurations = {
    enki = mkNixos "enki" "2a01:4f9:c012:7e2c::1";
    utu = mkNixos "utu" "2a01:4f9:c012:3826::1";
  };
};
}

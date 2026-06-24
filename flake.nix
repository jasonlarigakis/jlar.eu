 {
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     llm-agents.url = "github:numtide/llm-agents.nix";
     disko.url = "github:nix-community/disko";
     disko.inputs.nixpkgs.follows = "nixpkgs";
   };
 
   outputs = { self, nixpkgs, llm-agents, disko, ... }@inputs:
 let
   mkNixos = name:
     nixpkgs.lib.nixosSystem {
       system = "x86_64-linux";
       specialArgs = { inherit inputs; hostName = name; };
       modules = [
         disko.nixosModules.disko
         ./disko.nix
         ./configuration.nix
       ];
     };
 in {
   nixosConfigurations = {
     enki = mkNixos "enki";
     utu = mkNixos "utu";
   };
 };
}

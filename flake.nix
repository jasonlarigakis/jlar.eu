 {
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     llm-agents.url = "github:numtide/llm-agents.nix";
   };
 
   outputs = { self, nixpkgs, llm-agents, ... }@inputs:
 let
   mkNixos = name: nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = { inherit inputs; hostName = name; };
     modules = [
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

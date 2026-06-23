 {
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
     llm-agents.url = "github:numtide/llm-agents.nix";
   };
 
   outputs = { self, nixpkgs, llm-agents, ... }@inputs: {
     nixosConfigurations = {
       enki = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };   # makes `inputs` available in modules
         modules = [
           ./configuration.nix
         ];
       };
     };
   };
 }

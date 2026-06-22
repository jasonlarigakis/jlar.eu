 {
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
   };
 
   outputs = { nixpkgs, ... }: {
     nixosConfigurations = {
       enki = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [
           ./configuration.nix
         ];
       };
     };
   };
 }

{
  description = "Dev shell for hexo project";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [ hexo-cli nodejs python314 libwebp ];

        shellHook = ''
          echo "Nix dev shell"
        '';
      };
    };
}


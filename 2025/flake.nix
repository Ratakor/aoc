{
  description = "AoC 2025 with OCaml";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      forAllSystems = f: builtins.mapAttrs f nixpkgs.legacyPackages;
    in
    {
      # nix run . -- <day> [<filename>]
      packages = forAllSystems (
        system: pkgs:
        let
          lib = pkgs.lib;
          fs = lib.fileset;
        in
        {
          default = self.packages.${system}.aoc;
          aoc = pkgs.ocamlPackages.buildDunePackage {
            pname = "aoc";
            version = "0.1.0";
            duneVersion = "3";
            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./dune-project
                ./lib
                ./bin
              ];
            };
            buildInputs = builtins.attrValues {
              inherit (pkgs)
                dune_3
                # opam
                ocaml
                ;
              # inherit (pkgs.ocamlPackages)
              #   cohttp-lwt-unix
              #   lwt_ssl
              #   ;
              # inherit (pkgs.ocamlPackages.janeStreet)
              #   ppx_expect
              #   ;
            };
          };
          strictDeps = true;
        }
      );

      devShells = forAllSystems (
        system: pkgs: {
          default = pkgs.mkShellNoCC {
            packages = builtins.attrValues {
              inherit (pkgs)
                dune_3
                # opam
                ocaml
                ;
              inherit (pkgs.ocamlPackages)
                cohttp-lwt-unix
                lwt_ssl
                ;
              inherit (pkgs.ocamlPackages.janeStreet)
                ppx_expect
                ;
            };
          };
        }
      );

      formatter = forAllSystems (_: pkgs: pkgs.nixfmt-tree);
    };
}

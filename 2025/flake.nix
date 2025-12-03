{
  description = "AoC 2025 with OCaml";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/x86_64-linux";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }:
    let
      lib = nixpkgs.lib;

      eachSystem = f: lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      treefmt = eachSystem (
        pkgs:
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            ocamlformat.enable = true;
          };
        }
      );
    in
    {
      # nix run . -- <day> [<filename>]
      # dune exec aoc <day> [<filename>]
      packages = eachSystem (
        pkgs:
        let
          lib = pkgs.lib;
          fs = lib.fileset;
        in
        {
          default = self.packages.${pkgs.system}.aoc;
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

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShellNoCC {
          packages = builtins.attrValues {
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
      });

      formatter = eachSystem (pkgs: treefmt.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmt.${pkgs.system}.config.build.check self;
      });
    };
}

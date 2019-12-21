

# https://github.com/haskell-distributed/network-transport-tcp/
# https://stackoverflow.com/questions/27968909/how-to-get-cabal-and-nix-work-together

# overriding...
# https://github.com/Gabriel439/haskell-nix/tree/master/project4
# https://stackoverflow.com/questions/56414329/how-do-i-override-a-haskell-package-with-a-git-local-package-with-nix-when-usi
# https://old.reddit.com/r/NixOS/comments/ebgkub/need_help_trying_to_use_ghc_810_with_nix/

# to fix cd network-transport-tcp/
# follow this, to create a local nix package, and make adjustments to cabal
# https://nixos.org/nixpkgs/manual/#how-to-create-nix-builds-for-your-own-private-haskell-packages


let
  config = {

    # works to suppress refusal to build!!
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = pkgs: rec {
      haskellPackages = pkgs.haskellPackages.override {
        overrides = haskellPackagesNew: haskellPackagesOld: rec {

          # network-transport-tcp-0.6.0 has a dependency on old version of containers
          # so we need master branch of network-transport-tcp
          # also remove tests which are in a separate module from cabal file
          network-transport-tcp = (haskellPackagesNew.callPackage /home/me/nixos-config/nix/network-transport-tcp/shell.nix { });

          # test fail...  disable tests
          # rank1dynamic-0.4.0
          rank1dynamic = pkgs.haskell.lib.dontCheck  haskellPackagesOld.rank1dynamic;

          # distributed-process-0.7.4 also has the same issue... a dependency on containers ==0.5.*,

        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };
in

pkgs.stdenv.mkDerivation {
  name = "my-example";

  buildInputs = [
    # pkgs.haskellPackages.network-transport-tcp

    pkgs.haskellPackages.project-m36
  ];

}


# haskellPackages.hindent
#haskellPackages.project-m36


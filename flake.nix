# ./flake.nix
{
  description = "Packages my private custom fonts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        privateFontRepoUrl = "https://github.com/your-username/your-private-font-repo.git";
        fontRev = "bb8fc9ddcbbb4539a686da960ba4e8c11d51d2e6"; # e.g., "a1b2c3d4e5f6..."
        fontSha256 = "sha256-L9TStVX8tNMLFVJuxkh0GS/mKnO5pFFtoIlCl9lNppE="; # e.g., "sha256-..." or "0si..."
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "TX-02";
          version = builtins.substring 0 7 fontRev; # Use short commit hash as version

          src = pkgs.fetchgit {
            url = privateFontRepoUrl;
            rev = fontRev;
            sha256 = fontSha256;
          };

          installPhase = ''
            runHook preInstall
            local font_dir="$out/share/fonts/opentype/${placeholder "pname"}-${placeholder "version"}"
            mkdir -p "$font_dir"
            cp -rT "$src/fonts" "$font_dir"
            runHook postInstall
          '';

          meta = {
            description = "Berkeley Mono TX-02 Font";
            license = pkgs.lib.licenses.unfree;
          };
        };

        # Optional: Alias for clarity
        packages.tx-02 = self.packages.${system}.default;
      }
    );
}

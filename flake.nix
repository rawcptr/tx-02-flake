# ./tx-02-flake/flake.nix
{
  description = "Packages my private custom fonts (BerkeleyMono OTF and TX-02 TTF)";

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

        privateFontRepoUrl = "https://github.com/rawcptr/tx-02.git";
        fontRev = "bb8fc9ddcbbb4539a686da960ba4e8c11d51d2e6";
        fontSha256 = "sha256-L9TStVX8tNMLFVJuxkh0GS/mKnO5pFFtoIlCl9lNppE=";
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          # Use a more descriptive pname if you like
          pname = "berkeley-tx02-fonts";
          version = builtins.substring 0 7 fontRev; # "bb8fc9d"

          src = pkgs.fetchgit {
            url = privateFontRepoUrl;
            rev = fontRev;
            sha256 = fontSha256;
          };

          # --- Updated installPhase ---
          installPhase = ''
            runHook preInstall

            local otf_font_dir="$out/share/fonts/opentype/${placeholder "pname"}-${placeholder "version"}"
            local ttf_font_dir="$out/share/fonts/truetype/${placeholder "pname"}-${placeholder "version"}"

            mkdir -p "$otf_font_dir"
            mkdir -p "$ttf_font_dir"

            local font_source_dir="$src/fonts"

            echo "Copying OTF fonts to $otf_font_dir"
            find "$font_source_dir" -type f -iname '*.otf' -print0 | xargs -0 cp -t "$otf_font_dir" --backup=none

            echo "Copying TTF fonts to $ttf_font_dir"
            find "$font_source_dir" -type f -iname '*.ttf' -print0 | xargs -0 cp -t "$ttf_font_dir" --backup=none

            # Verify copy (optional debug step)
            echo "Contents of OTF target:"
            ls -l "$otf_font_dir"
            echo "Contents of TTF target:"
            ls -l "$ttf_font_dir"

            runHook postInstall
          '';

          meta = {
            description = "Berkeley Mono Nerd Font (OTF) and TX-02 Font (TTF)";
            license = pkgs.lib.licenses.unfree; # Keep as unfree since source repo is private/fonts paid
          };
        };

        packages.berkeley-tx02-fonts = self.packages.${system}.default;
      }
    );
}

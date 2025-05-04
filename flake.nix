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

            echo "--- Font Flake Install Phase ---"
            echo "Source directory (\$src): $src"
            echo "Listing contents of \$src:"
            ls -la "$src"
            echo "-------------------------------"

            # --- Adjust this line based on your repo structure ---
            local font_source_dir="$src/fonts" # Or "$src", "$src/other_dir", etc.
            # -----------------------------------------------------

            echo "Attempting to use font source directory: $font_source_dir"
            echo "Checking if font source directory exists:"
            if [ -d "$font_source_dir" ]; then
              echo "Directory exists. Listing contents:"
              ls -la "$font_source_dir"
            else
              echo "ERROR: Directory $font_source_dir NOT FOUND!"
              # Optionally exit here if the dir must exist: exit 1
            fi
            echo "-------------------------------"


            local otf_font_dir="$out/share/fonts/opentype/${placeholder "pname"}-${placeholder "version"}"
            local ttf_font_dir="$out/share/fonts/truetype/${placeholder "pname"}-${placeholder "version"}"

            mkdir -p "$otf_font_dir"
            mkdir -p "$ttf_font_dir"

            echo "Copying OTF fonts to $otf_font_dir from $font_source_dir"
            # Using -v for verbose copy, || echo to report find/cp failures
            find "$font_source_dir" -maxdepth 1 -type f -iname '*.otf' -print -exec cp -vt "$otf_font_dir" --backup=none {} + || echo "Warning: No OTF files found or error during copy."
            # Added -maxdepth 1 assuming fonts are directly in font_source_dir, remove if they are nested deeper.
            # Added -print to see files found by find. Changed pipe to -exec {} + which is often more robust.

            echo "Copying TTF fonts to $ttf_font_dir from $font_source_dir"
            find "$font_source_dir" -maxdepth 1 -type f -iname '*.ttf' -print -exec cp -vt "$ttf_font_dir" --backup=none {} + || echo "Warning: No TTF files found or error during copy."

            echo "--- Final Check ---"
            echo "Contents of OTF target ($otf_font_dir):"
            ls -l "$otf_font_dir"
            echo "Contents of TTF target ($ttf_font_dir):"
            ls -l "$ttf_font_dir"

            if [ -z "$(ls -A $otf_font_dir)" ] && [ -z "$(ls -A $ttf_font_dir)" ]; then
               echo "ERROR: Both target font directories are empty. Install failed."
               # Consider exiting with error: exit 1
            fi
            echo "------------------"

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

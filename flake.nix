# ==================================================================================================
# flake-catalog
# ==================================================================================================

{
  description = "Versioned Nix flake catalog for Hakula's projects";

  nixConfig = {
    extra-substituters = [ "https://hakula.cachix.org" ];
    extra-trusted-public-keys = [
      "hakula.cachix.org-1:7zwB3fhMfReHdOjh6DmnaLXgqbPDBcojvN9F+osZw0k="
    ];
  };

  # ------------------------------------------------------------------------------------------------
  # Inputs
  # ------------------------------------------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    devkit = {
      url = "github:hakulab/devkit/v3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    activity-report.url = "github:hakulab/activity-report";
    agent-project-move.url = "github:hakulab/agent-project-move";
    claude-statusline.url = "github:hakulab/claude-statusline";
    listenbrainz-scrobbler.url = "github:hakulab/listenbrainz-scrobbler";
    oxide-code.url = "github:hakulab/oxide-code";
    plugins.url = "github:hakulab/plugins";
    wakatime-cli.url = "github:hakulab/wakatime-cli";
  };

  # ------------------------------------------------------------------------------------------------
  # Outputs
  # ------------------------------------------------------------------------------------------------
  outputs =
    {
      self,
      nixpkgs,
      devkit,
      activity-report,
      agent-project-move,
      claude-statusline,
      listenbrainz-scrobbler,
      oxide-code,
      plugins,
      wakatime-cli,
      ...
    }@inputs:
    {
      homeModules = {
        activity-report = activity-report.homeModules.default;
        agent-project-move = agent-project-move.homeModules.default;
        claude-statusline = claude-statusline.homeModules.default;
        listenbrainz-scrobbler = listenbrainz-scrobbler.homeModules.default;
        oxide-code = oxide-code.homeModules.default;
      };

      lib.skills = plugins.lib.skills;

      overlays.default =
        _: prev:
        nixpkgs.lib.optionalAttrs (
          prev.stdenv.buildPlatform == prev.stdenv.hostPlatform
          && prev.stdenv.hostPlatform == prev.stdenv.targetPlatform
          && !(prev.stdenv.hostPlatform.isStatic or false)
          && !(prev.stdenv.hostPlatform.isMusl or false)
        ) (self.packages.${prev.stdenv.hostPlatform.system} or { });
    }
    // devkit.lib.eachSystem devkit.lib.systems (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dk = devkit.lib.mkLib pkgs;

        preCommit = dk.preCommit {
          src = ./.;
          hooks = {
            markdownlint-cli2.settings.configPath = "";
            prettier = {
              enable = true;
              settings.configPath = "";
            };
            shellcheck.enable = true;
            shfmt.enable = true;
          };
        };
      in
      {
        # ------------------------------------------------------------------------------------------
        # Dev Shell
        # ------------------------------------------------------------------------------------------
        devShells.default = pkgs.mkShell {
          name = "flake-catalog-dev";
          inputsFrom = [ preCommit ];
        };

        # ------------------------------------------------------------------------------------------
        # Packages
        # ------------------------------------------------------------------------------------------
        packages = {
          activity-report = activity-report.packages.${system}.activity-report;
          agent-project-move = agent-project-move.packages.${system}.agent-project-move;
          claude-statusline = claude-statusline.packages.${system}.claude-statusline;
          oxide-code = oxide-code.packages.${system}.oxide-code;
          wakatime-cli = wakatime-cli.packages.${system}.wakatime-cli;
        }
        // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
          listenbrainz-scrobbler = listenbrainz-scrobbler.packages.${system}.listenbrainz-scrobbler;
        };

        # ------------------------------------------------------------------------------------------
        # Checks
        # ------------------------------------------------------------------------------------------
        checks = self.packages.${system} // import ./nix/checks.nix { inherit pkgs inputs self; };

        # ------------------------------------------------------------------------------------------
        # Formatter
        # ------------------------------------------------------------------------------------------
        formatter = pkgs.nixfmt-tree;
      }
    );
}

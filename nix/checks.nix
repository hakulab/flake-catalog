# ==================================================================================================
# Catalog Integration Checks
# ==================================================================================================

{
  pkgs,
  inputs,
  self,
}:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv.hostPlatform) system;

  # ------------------------------------------------------------------------------------------------
  # Packages and Overlay
  # ------------------------------------------------------------------------------------------------
  packages = self.packages.${system};
  upstreamPackages = {
    inherit (inputs.activity-report.packages.${system}) activity-report;
    inherit (inputs.agent-project-move.packages.${system}) agent-project-move;
    inherit (inputs.claude-statusline.packages.${system}) claude-statusline;
    inherit (inputs.oxide-code.packages.${system}) oxide-code;
    inherit (inputs.wakatime-cli.packages.${system}) wakatime-cli;
  }
  // lib.optionalAttrs isDarwin {
    inherit (inputs.listenbrainz-scrobbler.packages.${system}) listenbrainz-scrobbler;
  };

  packagePaths = lib.mapAttrs (
    _: package: {
      inherit (package) drvPath outPath;
    }
  );

  crossTarget =
    packageSet:
    if system == "aarch64-linux" then
      packageSet.pkgsCross.gnu64
    else
      packageSet.pkgsCross.aarch64-multiplatform;

  crossPackagePaths =
    packageSet:
    packagePaths {
      inherit ((crossTarget packageSet).pkgsStatic) hello;
    };

  overlay = pkgs.extend self.overlays.default;

  # ------------------------------------------------------------------------------------------------
  # Home Manager Evaluation
  # ------------------------------------------------------------------------------------------------
  username = "catalog-test";

  moduleNames = [
    "activity-report"
    "agent-project-move"
    "claude-statusline"
    "oxide-code"
  ]
  ++ lib.optional isDarwin "listenbrainz-scrobbler";

  homeFixture = skills: {
    home = {
      inherit username;
      homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
      stateVersion = "26.05";
      file = lib.mapAttrs' (
        name: source: lib.nameValuePair ".agents/skills/${name}" { inherit source; }
      ) skills;
    };

    programs = {
      activity-report = {
        enable = true;
        settings = {
          labels.default = [ "work" ];
        };
      };

      agent-project-move.enable = true;

      claude-statusline.enable = true;

      oxide-code = {
        enable = true;
        settings.client.effort = "high";
        context = "Use the project instructions.\n";
      };
    };

    services = lib.optionalAttrs isDarwin {
      listenbrainz-scrobbler.enable = true;
    };
  };

  evalHome =
    packageSet: modules: skills:
    (inputs.home-manager.lib.homeManagerConfiguration {
      modules = modules ++ [
        (homeFixture skills)
      ];
      # Reconstructing either Nushell package with the host's zstd must change its derivation.
      pkgs = packageSet.extend (_: prev: { zstd = prev.hello; });
    }).config;

  snapshot = config: {
    packages = map (package: package.drvPath) config.home.packages;
    files = lib.mapAttrs (_: file: {
      source = toString file.source;
      inherit (file) text;
    }) config.home.file;
    launchd = lib.optionalAttrs isDarwin config.launchd.agents;
  };

  catalog = evalHome overlay (map (name: self.homeModules.${name}) moduleNames) self.lib.skills;
  upstream = evalHome pkgs (map (
    name: inputs.${name}.homeModules.default
  ) moduleNames) inputs.plugins.lib.skills;

  installed = map (package: package.drvPath) catalog.home.packages;
  skillSource = name: toString catalog.home.file.".agents/skills/${name}".source;
in
{
  # ------------------------------------------------------------------------------------------------
  # Overlay Check
  # ------------------------------------------------------------------------------------------------
  overlay =
    assert lib.assertMsg (
      packagePaths packages == packagePaths upstreamPackages
    ) "catalog package identity differs from upstream";
    assert lib.assertMsg (
      packagePaths (builtins.intersectAttrs packages overlay) == packagePaths upstreamPackages
    ) "catalog overlay package identity differs from upstream";
    assert lib.assertMsg (
      self.overlays.default null pkgs.pkgsStatic == { }
    ) "catalog overlay modified pkgsStatic";
    assert lib.assertMsg (
      lib.optionalAttrs pkgs.stdenv.isLinux (self.overlays.default null pkgs.pkgsMusl) == { }
    ) "catalog overlay modified pkgsMusl";
    assert lib.assertMsg (
      self.overlays.default null (crossTarget pkgs) == { }
    ) "catalog overlay modified pkgsCross";
    assert lib.assertMsg (
      crossPackagePaths overlay == crossPackagePaths pkgs
    ) "catalog overlay cross-package identity differs from nixpkgs";
    pkgs.emptyFile;

  # ------------------------------------------------------------------------------------------------
  # Home Manager Check
  # ------------------------------------------------------------------------------------------------
  home-manager =
    assert lib.assertMsg (
      snapshot catalog == snapshot upstream
    ) "catalog Home Manager configuration differs from direct upstream imports";
    assert lib.assertMsg (lib.all (
      name: builtins.elem upstreamPackages.${name}.drvPath installed
    ) moduleNames) "Home Manager defaults did not install the locked upstream packages";
    assert lib.assertMsg (
      lib.all (name: skillSource name == "${upstreamPackages.${name}}/share/skills/${name}") [
        "activity-report"
        "agent-project-move"
      ]
      && lib.all (name: skillSource name == toString inputs.plugins.lib.skills.${name}) (
        builtins.attrNames inputs.plugins.lib.skills
      )
    ) "Home Manager skill links differ from their upstream sources";
    pkgs.emptyFile;
}

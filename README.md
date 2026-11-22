# flake-catalog

[![CI](https://github.com/hakula139/flake-catalog/actions/workflows/ci.yml/badge.svg)](https://github.com/hakula139/flake-catalog/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Versioned Nix flake catalog for Hakula's projects. Packages are the upstream derivations, with each project's locked dependencies and toolchain preserved.

## Outputs

Packages use `packages.<system>.<name>`. Original Home Manager modules use `homeModules.<name>`.

| Name                                               | aarch64-darwin | aarch64-linux | x86_64-linux | Home Manager |
| -------------------------------------------------- | -------------- | ------------- | ------------ | ------------ |
| [`activity-report`][activity-report]               | Yes            | Yes           | Yes          | Yes          |
| [`agent-project-move`][agent-project-move]         | Yes            | Yes           | Yes          | Yes          |
| [`listenbrainz-scrobbler`][listenbrainz-scrobbler] | Yes            |               |              | Darwin       |
| [`oxide-code`][oxide-code]                         | Yes            | Yes           | Yes          | Yes          |
| [`wakatime-cli`][wakatime-cli]                     | Yes            | Yes           | Yes          |              |

`lib.skills` exposes [Plugins](https://github.com/hakula139/plugins)' skill sources. `overlays.default` aliases those packages in the consumer's package set.

## Consume

Add the input and commit the resulting lock:

```nix
inputs.flake-catalog.url = "github:hakula139/flake-catalog";
```

Append an existing release tag to the input URL to pin a catalog version.

Keep the catalog's project inputs and transitive dependencies unchanged, without consumer `follows` overrides. Overriding them changes the tested derivations.

Select packages directly:

```nix
environment.systemPackages = [
  inputs.flake-catalog.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-cli
];
```

Each Home Manager module selects its locked upstream package by default on supported native platforms.

```nix
imports = [ inputs.flake-catalog.homeModules.activity-report ];
programs.activity-report.enable = true;
```

To access catalog packages through `pkgs`, add `inputs.flake-catalog.overlays.default` to `nixpkgs.overlays` and select `pkgs.activity-report`. Install individual skill sources through `home.file`:

```nix
home.file.".agents/skills/review".source = inputs.flake-catalog.lib.skills.review;
```

## Cache

Input flakes' `nixConfig` is not inherited. Configure the cache in your root flake:

```nix
nixConfig = {
  extra-substituters = [ "https://hakula.cachix.org" ];
  extra-trusted-public-keys = [
    "hakula.cachix.org-1:7zwB3fhMfReHdOjh6DmnaLXgqbPDBcojvN9F+osZw0k="
  ];
};
```

For NixOS / nix-darwin, put the same settings under `nix.settings`, following the host's trust policy.

## Versioning

Catalog versions are independent of project versions. Removing or renaming an output or dropping a platform requires a major version. Additions are minor, and compatible corrections and project updates are patch changes unless an integration contract changes.

## Development

```bash
nix develop
run-hooks
nix flake check --all-systems
```

See devkit's shared [CI](https://github.com/hakulab/devkit/blob/v3/docs/ci.md) and [release procedures](https://github.com/hakulab/devkit/blob/v3/docs/releasing.md).

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz). Licensed under the [MIT License](LICENSE).

[activity-report]: https://github.com/hakula139/activity-report
[agent-project-move]: https://github.com/hakula139/agent-project-move
[listenbrainz-scrobbler]: https://github.com/hakula139/listenbrainz-scrobbler
[oxide-code]: https://github.com/hakula139/oxide-code
[wakatime-cli]: https://github.com/hakula139/wakatime-cli

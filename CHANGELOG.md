# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-11-27

### Added

- Add Claude Statusline (`v1.0.0-rc.2`) as a package on `aarch64-darwin`, `aarch64-linux`, and `x86_64-linux` and as `homeModules.claude-statusline`, including configurable theme presets, per-slot overrides, and `NO_COLOR` support ([#31](https://github.com/hakulab/flake-catalog/pull/31), [#32](https://github.com/hakulab/flake-catalog/pull/32), [#33](https://github.com/hakulab/flake-catalog/pull/33), [#34](https://github.com/hakulab/flake-catalog/pull/34)).

### Changed

- Migrate catalog flake inputs, shared tooling, and documentation links from `hakula139` to `hakulab` ([#22](https://github.com/hakulab/flake-catalog/pull/22), [#23](https://github.com/hakulab/flake-catalog/pull/23), [#24](https://github.com/hakulab/flake-catalog/pull/24), [#25](https://github.com/hakulab/flake-catalog/pull/25), [#26](https://github.com/hakulab/flake-catalog/pull/26)).
- Refresh `flake.lock` inputs across `nixpkgs`, `home-manager`, `devkit` (to `v3.8.3`), `plugins` (to `349743a`, updating code-layout, Git workflow, Nix, and Markdown guidance), and the remaining upstream project locks ([#19](https://github.com/hakulab/flake-catalog/pull/19), [#20](https://github.com/hakulab/flake-catalog/pull/20), [#27](https://github.com/hakulab/flake-catalog/pull/27), [#28](https://github.com/hakulab/flake-catalog/pull/28), [#30](https://github.com/hakulab/flake-catalog/pull/30), [#32](https://github.com/hakulab/flake-catalog/pull/32)).
- Document channel semantics in `README.md`, distinguishing release tags as stable pinned snapshots from floating `main` as the unstable channel ([#35](https://github.com/hakulab/flake-catalog/pull/35)).

### Fixed

- Update WakaTime CLI to `v2.28.4-hakula.4` to improve AI project attribution, preserve project switches during heartbeat compaction, fix Git checkout path handling, and improve batch delivery and offline retries ([#21](https://github.com/hakulab/flake-catalog/pull/21)).
- Update Oxide Code to `v0.1.0-alpha.13` to exclude `/` from bracket character classes and support POSIX character classes in permission path globs, guard modified keys in TUI modals, and fix `Ctrl+Home` / `Ctrl+End` chat scrolling ([#29](https://github.com/hakulab/flake-catalog/pull/29), [#32](https://github.com/hakulab/flake-catalog/pull/32)).

[0.3.0]: https://github.com/hakulab/flake-catalog/compare/v0.2.0...v0.3.0

## [0.2.0] - 2026-11-18

### Breaking changes

- Update Agent Project Move to v0.5.0, which requires v0.4.0 or newer on both hosts for OMP blob bundles and removes the standalone `export-blobs` subcommand in favor of direct attachment recovery in the skill ([#8](https://github.com/hakula139/flake-catalog/pull/8), [#11](https://github.com/hakula139/flake-catalog/pull/11)).

### Added

- Export Activity Report, Agent Project Move, Oxide Code, and WakaTime CLI packages and checks on `aarch64-linux` ([#10](https://github.com/hakula139/flake-catalog/pull/10)).
- Update Agent Project Move to v0.5.0 with `move --session-ids` and `move --exact`, ListenBrainz Scrobbler to v0.4.1 with `overlays.default` on macOS, Activity Report to v0.2.2 with single-digit date components, Oxide Code to v0.1.0-alpha.12, WakaTime CLI to v2.28.4-hakula.3, and Plugins to `afa5a92` ([#9](https://github.com/hakula139/flake-catalog/pull/9), [#11](https://github.com/hakula139/flake-catalog/pull/11)).

### Changed

- Track upstream default branches in `flake.nix` while locking exact revisions in `flake.lock` so Renovate refreshes and auto-merges lock updates directly ([#11](https://github.com/hakula139/flake-catalog/pull/11)).
- Reuse each upstream flake's locked native derivation by default across all four Home Manager modules (`activity-report`, `agent-project-move`, `listenbrainz-scrobbler`, and `oxide-code`), removing the need to pass `package` explicitly ([#11](https://github.com/hakula139/flake-catalog/pull/11)).

### Fixed

- Guard the catalog overlay on static, musl, and cross package sets so auxiliary nixpkgs evaluations keep their native packages. Skip Home Manager's `oxide-code` configuration check when the builder cannot execute the cross-compiled binary ([#10](https://github.com/hakula139/flake-catalog/pull/10), [#11](https://github.com/hakula139/flake-catalog/pull/11)).
- Preserve Codex `guardian_review_feedback` rows and SQLite BLOBs across Agent Project Move transfers, align Activity Report local midnight boundaries across daylight-saving changes, announce initial ListenBrainz playback in a single request, and buffer session-based WakaTime AI heartbeats ([#9](https://github.com/hakula139/flake-catalog/pull/9), [#11](https://github.com/hakula139/flake-catalog/pull/11)).

[0.2.0]: https://github.com/hakula139/flake-catalog/compare/v0.1.2...v0.2.0

## [0.1.2] - 2026-11-15

### Changed

- Make Dream proposals resumable across sessions and refresh issue-title and Nushell guidance.

### Fixed

- Fix infinite recursion when applying the catalog overlay to nixpkgs, allowing consumer development shells to evaluate.
- Update Activity Report to v0.2.1 to retain native Codex agent time and exclude imported spans while preserving native continuations.

[0.1.2]: https://github.com/hakula139/flake-catalog/compare/v0.1.1...v0.1.2

## [0.1.1] - 2026-11-15

### Fixed

- Update the Git workflow skill exposed through `lib.skills` to poll GitHub checks and workflow runs every 60 seconds while waiting for completion.

[0.1.1]: https://github.com/hakula139/flake-catalog/compare/v0.1.0...v0.1.1

## [0.1.0] - 2026-11-15

### Added

- Install Activity Report, Agent Project Move, Oxide Code, and WakaTime CLI through named packages on x86_64 Linux and Apple Silicon macOS. ListenBrainz Scrobbler is available on Apple Silicon macOS.
- Import the original Home Manager modules through `homeModules.activity-report`, `homeModules.agent-project-move`, `homeModules.listenbrainz-scrobbler`, and `homeModules.oxide-code`.
- Access Plugins' skill sources through `lib.skills` and fixed package aliases through `overlays.default`. Direct packages and overlay aliases preserve each upstream project's locked dependency graph and toolchain.

[0.1.0]: https://github.com/hakula139/flake-catalog/releases/tag/v0.1.0

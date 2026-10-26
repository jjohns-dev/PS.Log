# AGENTS.md

`PS.Log` is a dependency-free trace-logging module for Windows PowerShell 5.1 and PowerShell 7. Install, usage and the six exported commands are in [README.md](README.md).

## Layout

| Path | Contents |
| ---- | -------- |
| `Public/` | One exported function per file. A new one must also be added to `FunctionsToExport` in `PS.Log.psd1`; the manifest, not `PS.Log.psm1`, controls exports. |
| `Private/` | Placeholder only; no private functions. |
| `Tests/Unit/` | One `Verb-Noun.tests.ps1` per public function. |
| `Tests/Common/` | Help, manifest and meta tests run against every export. |
| `Build/` | `build.ps1` entry point, psake tasks, `depend.psd1` pins, analyzer settings. |

## Validating a change

Pins in `Build/depend.psd1`: Pester 6.2.0, psake 5.0.4, PSScriptAnalyzer 1.25.0.

```pwsh
./Build/build.ps1 -ResolveDependency -TaskList Init   # first run on a machine
./Build/build.ps1 -TaskList Analyze
./Build/build.ps1 -TaskList Test                      # Default runs Test
./Build/build.ps1 -TaskList Cleanup
```

- `build.ps1` sets `$env:BHProjectPath`, `BHProjectName` and `BHPSModuleManifest` itself; tests read them. The `BH` prefix is a leftover from BuildHelpers, which is no longer a dependency.
- There is no root `.gitignore`, so `Analyze` and `Test` leave `Staging/` and `Artifacts/` as untracked files. Run `Cleanup` before committing.
- `Analyze` scans `Staging/` (module sources and manifest) only, never `Tests/` or `Build/`.

## CI

Every workflow calls `jjohns-dev/pwsh-module-ci` at `@v1`.

| Workflow | Calls | Trigger |
| -------- | ----- | ------- |
| `ci.yml` | `ci.yml`, `os-matrix: ["ubuntu-latest"]`, `min-tests: 87` | PRs, push to `main` |
| `pssa-sarif.yml` | `pssa-sarif.yml` | PR to `main`, push to `main` |
| `release.yml` | `release.yml` | `v<x.y.z>` tag push |

The shared `ci.yml` re-checks the JUnit file in a "Verify Pester results" step and fails on container/discovery errors or fewer than `min-tests` collected. What CI does not do:

- Run on Windows or macOS.
- Publish anything on merge. A release needs a `v<x.y.z>` tag push.

## Conventions

- `main` ruleset `protect`: PR required, signed commits, linear history, required status checks, no force-push or deletion. `main` has no merge commits; PRs land as one commit with a `(#N)` suffix.
- Recent subjects are conventional commits (`fix(Build):`, `docs:`, `ci:`); older ones are plain imperative. Branch names follow no convention.

## Gotchas that have bitten here

- **`Tests/Common/Help.Tests.ps1` is a template shared across repos** (jjohns-dev/pwsh-module-ci#17). Its mandatory-value test was deleted on purpose because it compared `Get-Help`'s `Required` to the attribute it is derived from. Do not re-add it from a sibling repo. No other test covers `Mandatory`.
- **`-ForEach` sources bind at discovery.** Before #54, `$HelpParameterNames` was set only in `BeforeAll`, so 0 "matching help" cases ran. Any new `-ForEach` variable must be set in `BeforeDiscovery`.
- **The psake `Test` gate checks `$TestResults.Result`, not `FailedCount`** (#52). A test file that throws at discovery reports `Failed: 0` yet fails the build. Do not "simplify" the gate back to `FailedCount`.

# blittermib-chart

[![CI](https://github.com/no42-org/blittermib-chart/actions/workflows/ci.yml/badge.svg)](https://github.com/no42-org/blittermib-chart/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/no42-org/blittermib-chart?label=chart)](https://github.com/no42-org/blittermib-chart/releases/latest)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/no42-org/blittermib-chart/badge)](https://scorecard.dev/viewer/?uri=github.com/no42-org/blittermib-chart)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Helm chart for [blittermib](https://github.com/no42-org/blittermib) —
the self-hostable, browser-based SNMP MIB reference tool.

Extracted from the application repository so chart releases are
decoupled from application releases.

## Install

```bash
helm install blittermib oci://ghcr.io/no42-org/charts/blittermib --version <chart-version>
kubectl port-forward svc/blittermib 8080:8080   # then open http://localhost:8080
```

blittermib is **single-instance** (`replicaCount: 1`) — the SQLite
cache is per-pod, so it doesn't scale horizontally.

To try unreleased chart changes, `--version 0.0.0-main` installs the
preview built from the tip of `main`. It is signed but mutable,
overwritten by every merge, and carries no SBOM or provenance — don't
run it in production.

## Versioning

| field | meaning | source |
|---|---|---|
| chart `version` | this chart's own semver — the OCI tag | stamped from this repo's `vX.Y.Z` git tag |
| `appVersion` | the blittermib **application** release the chart is pinned to and CI-tested against | `Chart.yaml`, bumped deliberately by PR |

`image.tag` defaults to `appVersion`. The kind smoke in CI installs
the chart against the pinned image and asserts the full path:
standards served on first boot, then an import-drop round trip.

## Common values

| Value | Default | Purpose |
|-------|---------|---------|
| `persistence.enabled` | `false` | Persist the data volume — curated corpus, `import/` intake, and SQLite cache as one unit. Strongly recommended when importing MIBs (else an `emptyDir`: imports vanish on pod replacement; standards re-mirror from the image either way). Switches the deploy strategy to `Recreate`. |
| `uploads.enabled` | `false` | Enable the in-browser MIB upload (`BLITTERMIB_UPLOAD_ENABLED`); uploads run through the import pipeline. |
| `ingress.enabled` | `false` | Expose via a classic `Ingress`. |
| `httpRoute.enabled` | `false` | Expose via a Gateway API `HTTPRoute` (set `httpRoute.parentRefs`). Mutually exclusive with `ingress`. |

To seed MIBs declaratively, use an initContainer that copies files
into `/var/lib/blittermib/data/mibs/import/` — the import pipeline
routes them on boot.

The chart pins the official image (it bundles libsmi, which the
binary needs at runtime) — don't override `image.repository` with a
stripped rebuild.

## Verifying releases

Charts are signed with [cosign](https://github.com/sigstore/cosign)
keyless signing; the identity is **this repository's** release
workflow:

```bash
cosign verify ghcr.io/no42-org/charts/blittermib:<chart-version> \
  --certificate-identity-regexp='^https://github.com/no42-org/blittermib-chart/\.github/workflows/release\.yml@refs/tags/v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' \
  --certificate-oidc-issuer=https://token.actions.githubusercontent.com
```

Charts published before the extraction (≤ 0.10.0) were signed by the
application repository's `release.yml` instead — see the
[blittermib README](https://github.com/no42-org/blittermib#verifying-releases).

## Development

```bash
make lint         # helm lint + render guards
make template     # default + persistent renders
make package      # TAG=vX.Y.Z stamps the chart version into dist/
make lint-actions # actionlint + zizmor over .github/workflows
```

Releases: tag `vX.Y.Z` → CI runs the gates, packages, pushes to
`oci://ghcr.io/no42-org/charts`, signs the digest, and opens a draft
GitHub release with the SBOM and signed checksums. See
[RELEASING.md](RELEASING.md).

How to contribute — issue first, DCO sign-off, AI-assistance policy —
is in [CONTRIBUTING.md](CONTRIBUTING.md). Security reports go through
[SECURITY.md](SECURITY.md), never a public issue. Where to ask
questions: [SUPPORT.md](SUPPORT.md).

## License

MIT — see [LICENSE](LICENSE).

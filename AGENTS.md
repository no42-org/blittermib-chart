# AGENTS.md

Helm chart for [blittermib](https://github.com/no42-org/blittermib), a
self-hosted SNMP MIB browser. Chart only — no application code here.

## Commands

```bash
make lint           # helm lint + the render guards helm lint misses
make template       # default and persistence+uploads renders
make lint-actions   # actionlint + zizmor over .github/workflows
make docs           # regenerate charts/blittermib/README.md (helm-docs)
make package        # dist/ tarball; TAG=vX.Y.Z stamps the chart version
```

There is no unit-test suite. The real test is the kind smoke in
`.github/workflows/gates.yml`: it installs the chart against the
pinned image and asserts standards are served on first boot, then that
a file dropped into `import/` becomes a served module.

## Layout

`charts/blittermib/` is the chart; `templates/` renders a Deployment,
Service, ServiceAccount, Secret, PVC, and — mutually exclusively — an
Ingress **or** a Gateway API HTTPRoute. `.github/workflows/gates.yml`
holds the quality gates and is called by both `ci.yml` and
`release.yml`, so gates are never defined twice.

## Things to get right

- **Two versions, different lifecycles.** Chart `version` is stamped
  from the git tag at package time; `appVersion` pins the blittermib
  release the chart is tested against and moves only by deliberate PR.
  Never bump them together out of habit.
- **`make docs` in the same commit as any `Chart.yaml` version or
  `appVersion` bump.** The generated README ships inside the immutable
  published tarball; a missed regen means a permanently stale badge.
- **`ingress` and `httpRoute` are mutually exclusive** — enabling both
  fails the render on purpose, and `make lint` asserts that the guard
  still fires.
- **Single instance.** `replicaCount: 1` is not a placeholder; the
  SQLite cache is per-pod.
- **Don't override `image.repository`** — the official image bundles
  libsmi, which the binary needs at runtime.
- **Published chart versions are immutable.** Fix forward with a new
  version; never retag.
- Actions are pinned to a commit SHA with the full semver in a
  trailing comment. `make lint-actions` enforces this.

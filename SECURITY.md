# Security Policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Report it privately through GitHub:
[Report a vulnerability](https://github.com/no42-org/blittermib-chart/security/advisories/new).
That opens a private advisory only the maintainers can see.

If you cannot use GitHub advisories, email <ronny@no42.org>.

Expect an acknowledgement within a few days. Please give us a
reasonable window to ship a fix before disclosing publicly; we will
credit you in the advisory unless you would rather we didn't.

## Scope

This repository is the Helm chart. Chart-side issues are in scope:
insecure defaults in `values.yaml`, privilege or RBAC problems in the
rendered manifests, secret handling, and the release pipeline itself.

Vulnerabilities in the blittermib application or its container image
belong in
[no42-org/blittermib](https://github.com/no42-org/blittermib/security/advisories/new).

## Supported versions

Only the latest published chart version is supported. Published
versions are immutable — fixes ship as a new version, never as a
retag.

## Verifying what you install

Every published chart is cosign-signed and carries SLSA build
provenance. Verify before deploying — commands are in the
[README](README.md#verifying-releases) and [RELEASING.md](RELEASING.md).

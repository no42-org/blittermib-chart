# Support

## Where to ask

| You want to | Go to |
|---|---|
| Report a chart bug or request a chart feature | [Issues on this repo](https://github.com/no42-org/blittermib-chart/issues) |
| Report a bug in the MIB browser itself | [no42-org/blittermib issues](https://github.com/no42-org/blittermib/issues) |
| Report a security vulnerability | [SECURITY.md](SECURITY.md) — privately, never a public issue |
| Ask how to deploy something | An issue here with the `question` label |

This is a small project maintained in spare time. There is no SLA;
a clear, reproducible report gets answered fastest.

## Before opening an issue

Include the chart version, the `appVersion` in use, your Kubernetes
distribution and version, and the values you set. `helm template` output
for the failing configuration is worth more than a description of it.

Check first:

- [README](README.md) — install, the values table, versioning
- [`values.yaml`](charts/blittermib/values.yaml) — every key with its default
- [`charts/blittermib/README.md`](charts/blittermib/README.md) — generated reference

Two things catch people out: blittermib is **single-instance**
(`replicaCount: 1`, the SQLite cache is per-pod), and `ingress` and
`httpRoute` are **mutually exclusive** — enabling both fails the
render deliberately.

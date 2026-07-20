Closes #

## What changes

<!-- One or two sentences. What an operator sees, not the diff. -->

## Values surface

<!-- New or changed keys in values.yaml, verbatim, with defaults.
     "None" is a fine answer. -->

None.

## Checklist

- [ ] `make lint` and `make template` pass
- [ ] `make lint-actions` passes (only if `.github/workflows/` changed)
- [ ] `make docs` re-run in the same commit (only if `Chart.yaml`
      `version` or `appVersion` changed — the generated README is
      packaged into the immutable tarball)
- [ ] Commits are signed off (`git commit -s`), and AI-assisted ones
      carry an `Assisted-by:` trailer — see [CONTRIBUTING.md](../CONTRIBUTING.md)

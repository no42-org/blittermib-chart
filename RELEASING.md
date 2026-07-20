# Releasing

Chart releases are tag-driven and decoupled from application releases:
the `vX.Y.Z` tag publishes the chart, then a GitHub release documents
it for humans.

## Process

1. **Land everything for the release on `main`** via PR with CI green.

2. **Set the chart version.** `charts/blittermib/Chart.yaml`
   `version:` must equal the release being cut — add a
   `chore: set chart version X.Y.Z` commit if it doesn't.
   `appVersion` names the application release the chart is tested
   against; it is bumped deliberately by PR, never as part of tagging.
   **Run `make docs` in the same commit** — the README's version
   badges are generated from exactly these two fields and are packaged
   into the (immutable) published tarball, so a bump without the regen
   ships stale badges forever (this bit v0.5.5).

3. **Tag and push** — this is the publication trigger:

   ```bash
   git tag -a vX.Y.Z -m "blittermib chart X.Y.Z — <one-line summary>"
   git push origin vX.Y.Z
   ```

   `release.yml` re-runs the full quality gates, packages the chart
   (version stamped from the tag), pushes it to
   `oci://ghcr.io/no42-org/charts`, cosign-signs the digest, attests
   SLSA build provenance, and creates a **draft** GitHub release with
   the tarball, SBOM, and signed checksums attached. Watch it:
   `gh run watch $(gh run list --workflow=release.yml
   --limit 1 --json databaseId -q '.[0].databaseId')`.

4. **Publish the draft** with a concise, curated note. The workflow
   already created the release and attached the artifacts — write the
   note and flip it out of draft, never create it by hand:

   ```bash
   gh release edit vX.Y.Z --notes-file <notes.md> --draft=false
   ```

   Note guidelines — curate, don't generate:
   - Lead with what an operator sees: behavior changes first, then new
     values keys, then internals. One bullet per change, link the PR.
   - Name new or changed `values.yaml` keys verbatim.
   - Call out the `appVersion` floor whenever it moves, and any
     compatibility constraint (e.g. "requires app ≥ X").
   - Mark breaking changes **BREAKING** at the top.
   - Include the install one-liner for the new version.
   - No commit-log dumps, no auto-generated "what's changed" lists.

5. **Verify the publication:**

   ```bash
   helm show chart oci://ghcr.io/no42-org/charts/blittermib --version X.Y.Z
   ```

   plus the cosign verification command from the README, and the
   build provenance:

   ```bash
   gh attestation verify oci://ghcr.io/no42-org/charts/blittermib:X.Y.Z \
     --repo no42-org/blittermib-chart
   ```

   The release's `checksums.txt` is signed too; verify it with the
   same identity as the chart:

   ```bash
   cosign verify-blob checksums.txt \
     --signature checksums.txt.sig --certificate checksums.txt.pem \
     --certificate-identity-regexp='^https://github.com/no42-org/blittermib-chart/\.github/workflows/release\.yml@refs/tags/v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' \
     --certificate-oidc-issuer=https://token.actions.githubusercontent.com
   ```

## Versioning rules

- Chart `version` follows semver: minor for behavioral or additive
  changes, patch for fixes with no values-surface change.
- **Published chart versions are immutable.** Once a version is in
  GHCR, never retag or republish it — consumers who pulled it would
  silently diverge, and the original digest's Rekor transparency-log
  entry persists either way. If a release is broken, cut the next
  version. The only exception is a release that was provably never
  consumed; pulling it back requires deleting the GHCR package
  versions (chart manifest, cosign signature, referrer) before
  re-tagging.

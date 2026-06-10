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

3. **Tag and push** — this is the publication trigger:

   ```bash
   git tag -a vX.Y.Z -m "blittermib chart X.Y.Z — <one-line summary>"
   git push origin vX.Y.Z
   ```

   `release.yml` packages the chart (version stamped from the tag),
   pushes it to `oci://ghcr.io/no42-org/charts`, and cosign-signs the
   digest. Watch it: `gh run watch $(gh run list --workflow=release.yml
   --limit 1 --json databaseId -q '.[0].databaseId')`.

4. **Create a GitHub release** with a concise, curated note:

   ```bash
   gh release create vX.Y.Z --verify-tag \
     --title "blittermib chart X.Y.Z" \
     --notes "<curated note>"
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

   plus the cosign verification command from the README.

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

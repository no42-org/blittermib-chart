# Contributing

Thanks for helping out. This repo holds the Helm chart only — the
application lives in [no42-org/blittermib](https://github.com/no42-org/blittermib).
Bugs in the MIB browser itself belong there; bugs in how it gets
deployed belong here.

## Workflow

1. **Open an issue first.** Work starts from an issue, not a drive-by
   pull request — it is where scope gets agreed before anyone writes
   YAML.
2. Branch, commit, and open a pull request that closes the issue
   (`Closes #123`).
3. CI must be green before merge. Run it locally first:

   ```bash
   make lint           # helm lint + render guards
   make template       # default and persistent renders
   make lint-actions   # actionlint + zizmor over .github/workflows
   ```

   `make lint-actions` needs `actionlint` and `zizmor` on your PATH
   (`brew install actionlint zizmor`).

4. Bumping `version` or `appVersion` in `charts/blittermib/Chart.yaml`
   means running `make docs` **in the same commit** — the generated
   chart README is packaged into the immutable published tarball, so a
   stale badge ships forever.

Pull requests are squash-merged, so the PR title becomes the commit
message on `main`. Give it a good one.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):
`<type>[scope]: <description>`, where type is one of `feat`, `fix`,
`docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`,
`revert`. Breaking changes append `!` or add a `BREAKING CHANGE:`
footer.

## Sign-off (DCO)

Every commit must carry a `Signed-off-by` trailer from a real human
identity — use `git commit -s`:

```
Signed-off-by: Jane Doe <jane@example.com>
```

This certifies the [Developer Certificate of Origin](https://developercertificate.org/):
you wrote the contribution, or you have the right to submit it under
the project's MIT license.

## AI-assisted contributions

AI assistance is welcome, and it must be disclosed. Add an
`Assisted-by` trailer naming the agent and model, above the sign-off:

```
Assisted-by: ClaudeCode:claude-opus-4-8
Signed-off-by: Jane Doe <jane@example.com>
```

The human who signs off remains fully responsible for the
contribution: for reviewing and understanding every line, for its
correctness, and for its license compliance. "The model wrote it" is
not a defence — an unreviewed AI patch with your sign-off on it is
your patch.

Do not commit AI tooling working directories; `.gitignore` already
excludes the ones we have seen.

## License

Contributions are licensed under the MIT License — see
[LICENSE](LICENSE).

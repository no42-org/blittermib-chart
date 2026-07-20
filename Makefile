# Helm chart for blittermib — https://github.com/no42-org/blittermib
.PHONY: docs lint lint-actions template package help

CHART_DIR := charts/blittermib
TAG ?=

# docs regenerates the chart README from Chart.yaml/values.yaml. Run it
# with every version/appVersion bump: the README is packaged into the
# published (immutable) chart tarball, so a stale badge ships forever.
docs:
	@command -v helm-docs >/dev/null 2>&1 || { echo "helm-docs not installed (brew install norwoodj/tap/helm-docs)"; exit 1; }
	helm-docs --chart-search-root charts

lint:
	helm lint $(CHART_DIR)
	@# Guard rails that `helm lint` doesn't cover.
	@if helm template blittermib $(CHART_DIR) \
		--set ingress.enabled=true --set httpRoute.enabled=true \
		--set 'httpRoute.parentRefs[0].name=x' >/dev/null 2>&1; then \
		echo "FAIL: ingress+httpRoute should be mutually exclusive"; exit 1; \
	else echo "OK: routing mutual-exclusion guard fires"; fi

# lint-actions checks the workflows themselves: actionlint for syntax
# and shell bugs inside `run:` blocks, zizmor for supply-chain issues
# (unpinned actions, template injection, over-broad permissions).
lint-actions:
	@command -v actionlint >/dev/null 2>&1 || { echo "actionlint not installed (brew install actionlint)"; exit 1; }
	@command -v zizmor >/dev/null 2>&1 || { echo "zizmor not installed (brew install zizmor)"; exit 1; }
	actionlint
	zizmor .github/workflows

template:
	helm template blittermib $(CHART_DIR) >/dev/null
	helm template blittermib $(CHART_DIR) \
		--set persistence.enabled=true --set uploads.enabled=true >/dev/null
	@echo "OK: default + persistent renders"

# package stamps the CHART version from TAG (vX.Y.Z, leading v
# stripped); appVersion stays pinned in Chart.yaml — it names the
# blittermib application release this chart is tested against.
package:
	@command -v helm >/dev/null 2>&1 || { echo "helm not installed"; exit 1; }
	mkdir -p dist
	@v="$${TAG#v}"; \
	if [ -n "$$v" ]; then \
		helm package $(CHART_DIR) --destination dist --version "$$v"; \
	else \
		helm package $(CHART_DIR) --destination dist; \
	fi

help:
	@echo "make docs      regenerate chart README via helm-docs (run with every bump)"
	@echo "make lint      helm lint + render guards"
	@echo "make lint-actions  actionlint + zizmor over .github/workflows"
	@echo "make template  render default and persistent variants"
	@echo "make package   build dist/ tarball (TAG=vX.Y.Z stamps the chart version)"

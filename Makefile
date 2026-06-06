# Helm chart for blittermib — https://github.com/no42-org/blittermib
.PHONY: lint template package smoke-install help

CHART_DIR := charts/blittermib
TAG ?=

lint:
	helm lint $(CHART_DIR)
	@# Guard rails that `helm lint` doesn't cover.
	@if helm template blittermib $(CHART_DIR) \
		--set ingress.enabled=true --set httpRoute.enabled=true \
		--set 'httpRoute.parentRefs[0].name=x' >/dev/null 2>&1; then \
		echo "FAIL: ingress+httpRoute should be mutually exclusive"; exit 1; \
	else echo "OK: routing mutual-exclusion guard fires"; fi

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
	@echo "make lint      helm lint + render guards"
	@echo "make template  render default and persistent variants"
	@echo "make package   build dist/ tarball (TAG=vX.Y.Z stamps the chart version)"

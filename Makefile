SHELL=/bin/bash -e -o pipefail

BUILD_DATE ?= $(shell date -u '+%Y-%m-%dT%H:%M:%SZ')

.PHONY: help
## help: print this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: lint
## lint: run markdown lint
lint:
	markdownlint-cli2 **/*.md

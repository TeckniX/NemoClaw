.PHONY: check lint format lint-ts format-ts docs docs-strict docs-live docs-clean image image-base push push-base

check:
	npx prek run --all-files
	@echo "All checks passed."

lint: check

# Targeted subproject checks (not part of `make check` — use for focused runs).
lint-ts:
	cd nemoclaw && npm run check

format: format-ts format-cli

format-cli:
	npx prettier --write 'bin/**/*.js' 'test/**/*.js'

format-ts:
	cd nemoclaw && npm run lint:fix && npm run format

# --- Docker images (buildx) ---

OWNER?=nvidia
IMAGE_REGISTRY?=ghcr.io
IMAGE_NAME:=$(IMAGE_REGISTRY)/$(OWNER)/nemoclaw
IMAGE_TAG:=$(shell git rev-parse --short HEAD)
IMAGE_BASE_NAME:=$(IMAGE_REGISTRY)/$(OWNER)/nemoclaw-base

image:
	docker buildx build \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		--load \
		.

image-base:
	docker buildx build \
		--file Dockerfile.base \
		--tag $(IMAGE_BASE_NAME):latest \
		--load \
		.

push:
	docker buildx build \
		--tag $(IMAGE_NAME):latest \
		--tag $(IMAGE_NAME):$(IMAGE_TAG) \
		--push \
		.

push-base:
	docker buildx build \
		--file Dockerfile.base \
		--tag $(IMAGE_BASE_NAME):latest \
		--push \
		.

# --- Documentation ---

docs:
	uv run --group docs sphinx-build -b html docs docs/_build/html

docs-strict:
	uv run --group docs sphinx-build -W -b html docs docs/_build/html

docs-live:
	uv run --group docs sphinx-autobuild docs docs/_build/html --open-browser

docs-clean:
	rm -rf docs/_build

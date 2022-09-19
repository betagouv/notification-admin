.DEFAULT_GOAL := help
SHELL := /bin/bash #bash | sh
DATE = $(shell date +%Y-%m-%dT%H:%M:%S)

PIP_ACCEL_CACHE ?= ${CURDIR}/cache/pip-accel
APP_VERSION_FILE = app/version.py

GIT_COMMIT ?= $(shell git rev-parse HEAD 2> /dev/null || echo "")

.PHONY: help
help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test:
	py.test --maxfail=1 -n4 --strict -p no:warnings $(TEST-FLAGS) tests/

.PHONY: run-dev
run-dev:
	pipenv run flask --debug run -p 6012 --host=0.0.0.0

.PHONY: lint-flake
lint-flake:
	flake8 .

.PHONY: lint-js-and-css
lint-js-and-css:
	npm run lint

.PHONY: order-check
order-check:
	isort --check-only ./app ./tests

.PHONY: js-tests
js-tests:
	npm test

.PHONY: format
format:
	isort ./app ./tests
	npx prettier --write app/assets/javascripts app/assets/stylesheets

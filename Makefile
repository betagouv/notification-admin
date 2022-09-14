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

.PHONY: babel-test
test-translations: babel
	pybabel extract -F babel.cfg -k _l -o /tmp/messages.po . && po2csv /tmp/messages.po /tmp/messages.csv
	rm /tmp/messages.po
	python scripts/test-translations.py /tmp/messages.csv
	rm /tmp/messages.csv

.PHONY: babel
babel:
	python scripts/generate_en_translations.py
	csv2po app/translations/csv/en.csv app/translations/en/LC_MESSAGES/messages.po
	csv2po app/translations/csv/fr.csv app/translations/fr/LC_MESSAGES/messages.po
	pybabel compile -d app/translations

.PHONY: search-csv
search-csv:
	python scripts/search_csv.py

.PHONY: coverage
coverage: venv ## Create coverage report
	. venv/bin/activate && coveralls

.PHONY: run-dev
run-dev:
	pipenv run flask run -p 6012 --host=0.0.0.0

.PHONY: lint-black
lint-black:
	black ./app ./tests --check

.PHONY: lint-flake
lint-flake:
	flake8 .

.PHONY: lint-js
lint-js:
	npm run lint

.PHONY: order-check
order-check:
	isort --check-only ./app ./tests

.PHONY: type-check
type-check:
	mypy ./

.PHONY: js-tests
js-tests:
	npm test

.PHONY: format
format:
	isort ./app ./tests
	black ./app ./tests
	npx prettier --write app/assets/javascripts app/assets/stylesheets

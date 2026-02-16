# Makefile

# Variables
PYTEST  = pytest --cov app --cov-append --cov-report=html -v $(OPTS)
TERRAFORM_DIR ?= ./terraform
ENV ?= dev
VERSION ?= latest
EKS_CLUSTER_NAME=$(shell cd $(TERRAFORM_DIR) && terraform output -raw cluster_name)
KUBECONFIG_PATH=$(HOME)/.kube/config

all: help

##
## Python environment targets
##

env:  ## create virtual environment with uv and install deps
	@echo "==> Creating virtual environment with uv"
	uv sync --group dev --group test

env_test: env  ## alias for env (uv sync installs everything)

requirements:  ## export pinned requirements.txt (for Docker builds)
	uv export --no-hashes --no-dev -o requirements/requirements.txt
	uv export --no-hashes --group test -o requirements/requirements-test.txt

##
## Formatting & code checks
##

format:  ## format code with ruff
	uv run ruff format .

format_check:  ## check code formatting with ruff
	uv run ruff format --check .

lint:  ## lint code with ruff
	uv run ruff check .

lint_fix:  ## lint and auto-fix with ruff
	uv run ruff check --fix .

mypy:  ## check python typing using mypy
	uv run mypy . --ignore-missing-imports

check: format_check lint mypy  ## run all code quality checks

##
## Tests & Coverage
##

unit:  ## run unit tests
	uv run --group test pytest -vvv -rPxf --cov=. --cov-append --cov-report term-missing tests

coverage:  ## coverage report
	uv run --group test coverage report --fail-under 90
	uv run --group test coverage html -i

pytest: unit coverage  ## run all tests and test coverage

test: check pytest  ## lint, type-check, then run tests

##
## Terraform-related targets
##

tf_clear: ## remove .terraform artifacts
	cd $(TERRAFORM_DIR) && rm -rf .terraform.lock.hcl .terraform

tf_init: ## run terraform init for the given ENV
	cd $(TERRAFORM_DIR) && terraform init -backend-config=./backends/$(ENV).backend -reconfigure

tf_fmt_validate: ## format & validate your Terraform
	cd $(TERRAFORM_DIR) && terraform fmt --recursive
	cd $(TERRAFORM_DIR) && terraform validate

tf_plan: ## run terraform plan for the given ENV and VERSION
	@echo "==> Terraform plan (ENV=$(ENV), VERSION=$(VERSION))"
	cd $(TERRAFORM_DIR) && \
		TF_VAR_service_version=$(VERSION) \
		terraform plan -var-file=$(ENV).tfvars -out="$(ENV).tfplan"

tf_apply: ## run terraform apply for the given ENV and VERSION
	@echo "==> Terraform apply (ENV=$(ENV), VERSION=$(VERSION))"
	cd $(TERRAFORM_DIR) && \
		TF_VAR_service_version=$(VERSION) \
		terraform apply "$(ENV).tfplan"

tf_outputs: ## run terraform output
	@echo "==> Terraform output (ENV=$(ENV), VERSION=$(VERSION))"
	cd $(TERRAFORM_DIR) && \
	terraform output

##
## K8s
##

kubeconfig: ## kubeconfig
	cd $(TERRAFORM_DIR) && terraform refresh
	aws eks update-kubeconfig --name $(EKS_CLUSTER_NAME)
	@echo "export KUBECONFIG=$(KUBECONFIG_PATH)"

##
## Help target
##

help: ## print help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

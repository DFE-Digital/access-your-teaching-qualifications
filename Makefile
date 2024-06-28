.DEFAULT_GOAL		:=help
SHELL				:=/bin/bash

TERRAFILE_VERSION=0.8
ARM_TEMPLATE_TAG=1.1.10
RG_TAGS={"Product" : "Access Your Teaching Qualifications"}
REGION=UK South
SERVICE_NAME=access-your-teaching-qualifications
SERVICE_SHORT=aytq
DOCKER_REPOSITORY=ghcr.io/dfe-digital/access-your-teaching-qualifications

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

##@ Set environment and corresponding configuration
.PHONY: dev
dev: ## set the dev enironment variables
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=dv)
	$(eval ENV_TAG=dev)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: test
test: ## set the test enironment variables
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=ts)
	$(eval ENV_TAG=test)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: preprod
preprod:  ## set the pre-production enironment variables
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=pp)
	$(eval ENV_TAG=pre-prod)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: production
production:  ## set the production enironment variables
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval RESOURCE_NAME_PREFIX=s165p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=prod)
	$(eval AZURE_BACKUP_STORAGE_ACCOUNT_NAME=s165p01aytqdbbackuppd)
	$(eval AZURE_BACKUP_STORAGE_CONTAINER_NAME=aytq)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})
	$(eval CONSOLE_OPTIONS=--sandbox)

.PHONY: review-init
review-init:
	$(if ${pr_id}, , $(error Missing environment variable "pr_id"))
	$(eval ENV_TAG=dev)

.PHONY: review
review: review-init set-azure-resource-group-tags
	$(eval DEPLOY_ENV=review)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=rv)
	$(eval ENV=-pr-${pr_id})
	$(eval backend_config=-backend-config="key=review/review${ENV}.tfstate")
	$(eval export TF_VAR_resource_group_tags=${RG_TAGS})
	$(eval export TF_VAR_app_suffix=${ENV})
	$(eval export TF_VAR_resource_group_name=s165d01-aytq-review${ENV}-rg)
	$(eval export TF_VAR_allegations_storage_account_name=s165d01aytqallegr${pr_id})
	$(eval NAME_ENV=${DEPLOY_ENV}${ENV})
	$(eval RESOURCE_ENV=${DEPLOY_ENV}${ENV})

.PHONY: domain
domain:
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval RESOURCE_NAME_PREFIX=s165p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=prod)

ci:	## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

set-azure-resource-group-tags: ##Tags that will be added to resource group on it's creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teaching Regulation Agency", "Product" : "Access Your Teaching Qualifications", "Service Line": "Teaching Workforce", "Service": "Teacher Training and Qualifications", "Service Offering": "Access Your Teaching Qualifications", "Environment" : "${ENV_TAG}"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.1)

.PHONY: read-keyvault-config
read-keyvault-config:
	$(eval KEY_VAULT_NAME=$(shell jq -r '.key_vault_name' terraform/workspace_variables/${DEPLOY_ENV}.tfvars.json))
	$(eval KEY_VAULT_SECRET_NAME=INFRASTRUCTURE)

read-deployment-config:
	$(eval POSTGRES_DATABASE_NAME="${RESOURCE_NAME_PREFIX}-aytq-${DEPLOY_ENV}${var.app_suffix}-psql-db")
	$(eval POSTGRES_SERVER_NAME="${RESOURCE_NAME_PREFIX}-aytq-${DEPLOY_ENV}${var.app_suffix}-psql.postgres.database.azure.com")

.PHONY: install-fetch-config
install-fetch-config: ## Install the fetch-config script, for viewing/editing secrets in Azure Key Vault
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

edit-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account ## make <env> edit-keyvault-secret -  edit (with default editor) keyvault secret for INFRASTRUCTURE
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

create-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account  ## make <env> create-keyvault-secret - create and edit  INFRASTRUCTURE secret
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-i -e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

print-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account ## make <env>  print-keyvault-secret -  print out keyvault secret for INFRASTRUCTURE
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

validate-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -d quiet \
		&& echo Data in ${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} looks valid

terraform-init: ## make <env> terraform-init - run terraform init against the <env> environment
	$(if ${IMAGE_TAG}, , $(eval export IMAGE_TAG=main))
	[[ "${SP_AUTH}" != "true" ]] && az account set -s ${AZURE_SUBSCRIPTION} || true
	terraform -chdir=terraform init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars ${backend_config} -upgrade -reconfigure

terraform-plan: terraform-init  ## make <env> terraform-plan - run terraform init against the <env> environment
	terraform -chdir=terraform plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

terraform-apply: terraform-init ## make <env> terraform-apply - run terraform init against the <env> environment
	terraform -chdir=terraform apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init ## ## make <env> terraform-destroy - run terraform init against the <env> environment
	terraform -chdir=terraform destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

deploy-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## make <env> deploy-azure-resources AUTO_APPROVE=1 - setup store for terraform state and keyvault storage,  use AUTO_APPROVE=1
	$(if ${AUTO_APPROVE}, , $(error can only run with AUTO_APPROVE))
	az deployment sub create --name "resourcedeploy-aytq-$(shell date +%Y%m%d%H%M%S)" -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqtfstate${ENV_SHORT}" "tfStorageContainerName=aytq-tfstate" \
			"dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-kv"

validate-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## make <env> validate-azure-resources - runs a '--what-if'
	az deployment sub create --name "resourcedeploy-aytq-$(shell date +%Y%m%d%H%M%S)" -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqtfstate${ENV_SHORT}" "tfStorageContainerName=aytq-tfstate" \
			"dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-kv" \
		--what-if

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## make domain domain-azure-resources AUTO_APPROVE=1
	$(if ${AUTO_APPROVE}, , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytqdomains-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqdomainstf" "tfStorageContainerName=aytqdomains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-aytqdomains-kv"

az-console: set-azure-account
	az container exec \
		--name=${RESOURCE_NAME_PREFIX}-aytq-${NAME_ENV}-wkr-cg \
		--resource-group=${RESOURCE_NAME_PREFIX}-aytq-${RESOURCE_ENV}-rg \
		--exec-command="bundle exec rails c ${CONSOLE_OPTIONS}"

# AKS
set-azure-account:
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

.PHONY: review-aks
review-aks: test-cluster
	$(if ${PR_NUMBER},,$(error Missing PR_NUMBER))
	$(eval ENVIRONMENT=review-${PR_NUMBER})
	$(eval export TF_VAR_environment=${ENVIRONMENT})
	$(eval include global_config/review.sh)

composed-variables:
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}${CONFIG_SHORT}tfsa)
	$(eval LOG_ANALYTICS_WORKSPACE_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-log)

test-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster:
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

set-what-if:
	$(eval WHAT_IF=--what-if)

arm-deployment: composed-variables set-azure-account
	$(if ${DISABLE_KEYVAULTS},, $(eval KV_ARG=keyVaultNames=${KEYVAULT_NAMES}))
	$(if ${ENABLE_KV_DIAGNOSTICS}, $(eval KV_DIAG_ARG=enableDiagnostics=${ENABLE_KV_DIAGNOSTICS} logAnalyticsWorkspaceName=${LOG_ANALYTICS_WORKSPACE_NAME}),)

	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "${REGION}" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_GROUP_NAME}" 'tags=${RG_TAGS}' \
		"tfStorageAccountName=${STORAGE_ACCOUNT_NAME}" "tfStorageContainerName=terraform-state" \
		${KV_ARG} \
		${KV_DIAG_ARG} \
		"enableKVPurgeProtection=${KV_PURGE_PROTECTION}" \
		${WHAT_IF}

deploy-arm-resources: arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

validate-arm-resources: set-what-if arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

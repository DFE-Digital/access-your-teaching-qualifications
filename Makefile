.DEFAULT_GOAL := help
SHELL := /bin/bash

### AKS ###
TERRAFILE_VERSION = 0.8
ARM_TEMPLATE_TAG = 1.1.10
RG_TAGS = {"Product" : "Access Your Teaching Qualifications"}
REGION = UK South
SERVICE_NAME = access-your-teaching-qualifications
SERVICE_SHORT = aytq
DOCKER_REPOSITORY = ghcr.io/dfe-digital/access-your-teaching-qualifications
### AKS ###

.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

### START: Legacy infrastructure - delete after AKS migration ###

##@ Set environment and corresponding configuration
.PHONY: dev
dev: ## Set the dev environment variables
	$(eval DEPLOY_ENV=dev)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-development)
	$(eval RESOURCE_NAME_PREFIX=s165d01)
	$(eval ENV_SHORT=dv)
	$(eval ENV_TAG=dev)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: test
test: ## Set the test environment variables
	$(eval DEPLOY_ENV=test)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=ts)
	$(eval ENV_TAG=test)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: preprod
preprod:  ## Set the pre-production environment variables
	$(eval DEPLOY_ENV=preprod)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-test)
	$(eval RESOURCE_NAME_PREFIX=s165t01)
	$(eval ENV_SHORT=pp)
	$(eval ENV_TAG=pre-prod)
	$(eval NAME_ENV=${DEPLOY_ENV})
	$(eval RESOURCE_ENV=${ENV_SHORT})

.PHONY: production
production:  ## Set the production environment variables
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
review: review-init set-azure-resource-group-tags ## Set the review environment variables
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
domain: ## Set the production environment variables for domain operations
	$(eval DEPLOY_ENV=production)
	$(eval AZURE_SUBSCRIPTION=s165-teachingqualificationsservice-production)
	$(eval RESOURCE_NAME_PREFIX=s165p01)
	$(eval ENV_SHORT=pd)
	$(eval ENV_TAG=prod)

set-azure-resource-group-tags: ## Tags that will be added to resource group on its creation in ARM template
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

edit-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account ## Edit (with default editor) Key Vault secret for INFRASTRUCTURE
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

create-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account ## Create and edit Key Vault secret for INFRASTRUCTURE
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} \
		-i -e -d azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml -c

print-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account ## Print out Key Vault secret for INFRASTRUCTURE
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -f yaml

validate-keyvault-secret: read-keyvault-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} -d quiet \
		&& echo Data in ${KEY_VAULT_NAME}/${KEY_VAULT_SECRET_NAME} looks valid

terraform-init: ## Run terraform init against the <env> environment
	$(if ${IMAGE_TAG}, , $(eval export IMAGE_TAG=main))
	[[ "${SP_AUTH}" != "true" ]] && az account set -s ${AZURE_SUBSCRIPTION} || true
	terraform -chdir=terraform init -backend-config workspace_variables/${DEPLOY_ENV}.backend.tfvars ${backend_config} -upgrade -reconfigure

terraform-plan: terraform-init  ## Run terraform plan against the <env> environment
	terraform -chdir=terraform plan -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json

terraform-apply: terraform-init ## Run terraform apply against the <env> environment
	terraform -chdir=terraform apply -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

terraform-destroy: terraform-init ## Run terraform destroy against the <env> environment
	terraform -chdir=terraform destroy -var-file workspace_variables/${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

deploy-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## Setup store for terraform state and Key Vault storage, use AUTO_APPROVE=1
	$(if ${AUTO_APPROVE}, , $(error can only run with AUTO_APPROVE))
	az deployment sub create --name "resourcedeploy-aytq-$(shell date +%Y%m%d%H%M%S)" -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqtfstate${ENV_SHORT}" "tfStorageContainerName=aytq-tfstate" \
			"dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" \
			 "keyVaultName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-kv"

validate-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## Runs a '--what-if' against Azure resources
	az deployment sub create --name "resourcedeploy-aytq-$(shell date +%Y%m%d%H%M%S)" -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqtfstate${ENV_SHORT}" "tfStorageContainerName=aytq-tfstate" \
			"dbBackupStorageAccountName=${AZURE_BACKUP_STORAGE_ACCOUNT_NAME}" "dbBackupStorageContainerName=${AZURE_BACKUP_STORAGE_CONTAINER_NAME}" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-aytq-${ENV_SHORT}-kv" \
		--what-if

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags ## Setup store for terraform state for domains, use AUTO_APPROVE=1
	$(if ${AUTO_APPROVE}, , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "West Europe" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-aytqdomains-rg" 'tags=${RG_TAGS}' "environment=${DEPLOY_ENV}" \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}aytqdomainstf" "tfStorageContainerName=aytqdomains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-aytqdomains-kv"

az-console: set-azure-account ## Access the Azure console
	az container exec \
		--name=${RESOURCE_NAME_PREFIX}-aytq-${NAME_ENV}-wkr-cg \
		--resource-group=${RESOURCE_NAME_PREFIX}-aytq-${RESOURCE_ENV}-rg \
		--exec-command="bundle exec rails c ${CONSOLE_OPTIONS}"

### END: Legacy infrastructure - delete after AKS migration ###

ci: ## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)

### AKS ###
# Note: AKS-specific files are found at the following locations, and do not conflict
# with the existing Azure deployment files:
# ./global_config/
# ./terraform/application

set-azure-account: ## Set the Azure account based on environment settings
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

.PHONY: aks-review
aks-review: test-cluster ## Setup review environment for AKS
	$(if ${PR_NUMBER},,$(error Missing PR_NUMBER))
	$(eval ENVIRONMENT=pr-${PR_NUMBER})
	$(eval include global_config/review.sh)

composed-variables: ## Compose variables needed for deployments
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}${CONFIG_SHORT}tfsa)
	$(eval LOG_ANALYTICS_WORKSPACE_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-log)

bin/terrafile: ## Install terrafile to manage terraform modules
	curl -sL https://github.com/coretech/terrafile/releases/download/v${TERRAFILE_VERSION}/terrafile_${TERRAFILE_VERSION}_$$(uname)_x86_64.tar.gz \
		| tar xz -C ./bin terrafile

aks-terraform-init: composed-variables bin/terrafile set-azure-account ## Initialize terraform for AKS
	$(if ${DOCKER_IMAGE_TAG}, , $(eval DOCKER_IMAGE_TAG=main))

	./bin/terrafile -p terraform/application/vendor/modules -f terraform/application/config/$(CONFIG)_Terrafile
	terraform -chdir=terraform/application init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=${ENVIRONMENT}_kubernetes.tfstate

	$(eval export TF_VAR_environment=${ENVIRONMENT})
	$(eval export TF_VAR_azure_resource_prefix=${AZURE_RESOURCE_PREFIX})
	$(eval export TF_VAR_config=${CONFIG})
	$(eval export TF_VAR_config_short=${CONFIG_SHORT})
	$(eval export TF_VAR_service_name=${SERVICE_NAME})
	$(eval export TF_VAR_service_short=${SERVICE_SHORT})
	$(eval export TF_VAR_docker_image=${DOCKER_REPOSITORY}:${DOCKER_IMAGE_TAG})
	$(eval export TF_VAR_resource_group_name=${RESOURCE_GROUP_NAME})

aks-terraform-plan: aks-terraform-init ## Plan terraform changes for AKS
	terraform -chdir=terraform/application plan -var-file "config/${CONFIG}.tfvars.json"

aks-terraform-apply: aks-terraform-init ## Apply terraform changes for AKS
	terraform -chdir=terraform/application apply -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

aks-terraform-destroy: aks-terraform-init ## Destroy terraform resources for AKS
	terraform -chdir=terraform/application destroy -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

test-cluster: ## Set up the test cluster variables for AKS
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189t01-tsc-ts-rg)
	$(eval CLUSTER_NAME=s189t01-tsc-test-aks)

production-cluster: ## Set up the production cluster variables for AKS
	$(eval CLUSTER_RESOURCE_GROUP_NAME=s189p01-tsc-pd-rg)
	$(eval CLUSTER_NAME=s189p01-tsc-production-aks)

set-what-if: ## Set the 'what-if' option for ARM deployment validation
	$(eval WHAT_IF=--what-if)

arm-deployment: composed-variables set-azure-account ## Deploy ARM resources
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

get-cluster-credentials: set-azure-account ## Get AKS cluster credentials
	az aks get-credentials --overwrite-existing -g ${CLUSTER_RESOURCE_GROUP_NAME} -n ${CLUSTER_NAME}
	kubelogin convert-kubeconfig -l $(if ${GITHUB_ACTIONS},spn,azurecli)

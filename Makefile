.DEFAULT_GOAL := help
SHELL := /bin/bash

### AKS ###
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

ci: ## Run in automation environment
	$(eval DISABLE_PASSCODE=true)
	$(eval AUTO_APPROVE=-auto-approve)
	$(eval SP_AUTH=true)
	$(eval SKIP_AZURE_LOGIN=true)

set-azure-account: ## Set the Azure account based on environment settings
	[ "${SKIP_AZURE_LOGIN}" != "true" ] && az account set -s ${AZURE_SUBSCRIPTION} || true

.PHONY: review
review: test-cluster ## Setup review environment for AKS
	$(if ${PR_NUMBER},,$(error Missing PR_NUMBER))
	$(eval ENVIRONMENT=pr-${PR_NUMBER})
	$(eval include global_config/review.sh)

.PHONY: test
test: test-cluster
	$(eval include global_config/test.sh)

.PHONY: preprod
preprod: test-cluster
	$(eval include global_config/preprod.sh)

.PHONY: production
production: production-cluster
	$(eval include global_config/production.sh)

.PHONY: domains
domains:
	$(eval include global_config/domains.sh)

# make qa railsc
.PHONY: railsc
railsc: get-cluster-credentials
	$(eval CONFIG_FILE=terraform/application/config/$(CONFIG).tfvars.json)
	$(if $(wildcard $(CONFIG_FILE)),,$(error Config file $(CONFIG_FILE) not found))
	$(eval NAMESPACE=$(shell jq -r '.namespace // empty' $(CONFIG_FILE)))
	$(if $(NAMESPACE),,$(error Namespace not found in $(CONFIG_FILE)))
	@echo "Using namespace: $(NAMESPACE)"
	@echo "Environment: $(CONFIG)"
	kubectl -n $(NAMESPACE) exec -ti deployment/access-your-teaching-qualifications-$(ENVIRONMENT) -- rails c

bin/konduit.sh:
	curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/main/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh

composed-variables: ## Compose variables needed for deployments
	$(eval RESOURCE_GROUP_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg)
	$(eval KEYVAULT_NAMES='("${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-app-kv", "${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-inf-kv")')
	$(eval STORAGE_ACCOUNT_NAME=${AZURE_RESOURCE_PREFIX}${SERVICE_SHORT}${CONFIG_SHORT}tfsa)
	$(eval LOG_ANALYTICS_WORKSPACE_NAME=${AZURE_RESOURCE_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-log)

.PHONY: vendor-modules
vendor-modules:
	rm -rf terraform/application/vendor/modules
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/application/vendor/modules/aks

terraform-init: composed-variables vendor-modules set-azure-account ## Initialize terraform for AKS
	$(if ${DOCKER_IMAGE_TAG}, , $(eval DOCKER_IMAGE_TAG=main))

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

terraform-plan: terraform-init ## Plan terraform changes for AKS
	terraform -chdir=terraform/application plan -var-file "config/${CONFIG}.tfvars.json"

terraform-apply: terraform-init ## Apply terraform changes for AKS
	terraform -chdir=terraform/application apply -var-file "config/${CONFIG}.tfvars.json" ${AUTO_APPROVE}

terraform-destroy: terraform-init ## Destroy terraform resources for AKS
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
	kubelogin convert-kubeconfig -l $(if ${AAD_LOGIN_METHOD},${AAD_LOGIN_METHOD},azurecli)

.PHONY: vendor-domain-infra-modules
vendor-domain-infra-modules:
	rm -rf terraform/domains/infrastructure/vendor/modules/domains
	TERRAFORM_MODULES_TAG=stable
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/domains/infrastructure/vendor/modules/domains

domains-infra-init: domains composed-variables vendor-domain-infra-modules set-azure-account
	terraform -chdir=terraform/domains/infrastructure init -reconfigure -upgrade \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=domains_infrastructure.tfstate

domains-infra-plan: domains domains-infra-init  ## Terraform plan for DNS infrastructure (DNS zone and front door). Usage: make domains-infra-plan
	terraform -chdir=terraform/domains/infrastructure plan -var-file config/zones.tfvars.json

domains-infra-apply: domains domains-infra-init  ## Terraform apply for DNS infrastructure (DNS zone and front door). Usage: make domains-infra-apply
	terraform -chdir=terraform/domains/infrastructure apply -var-file config/zones.tfvars.json ${AUTO_APPROVE}

.PHONY: vendor-domain-modules
vendor-domain-modules:
	rm -rf terraform/domains/environment_domains/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/domains/environment_domains/vendor/modules/domains

domains-init: domains composed-variables vendor-domain-modules set-azure-account
	terraform -chdir=terraform/domains/environment_domains init -upgrade -reconfigure \
		-backend-config=resource_group_name=${RESOURCE_GROUP_NAME} \
		-backend-config=storage_account_name=${STORAGE_ACCOUNT_NAME} \
		-backend-config=key=${ENVIRONMENT}.tfstate

domains-plan: domains-init  ## Terraform plan for DNS environment domains. Usage: make development domains-plan
	terraform -chdir=terraform/domains/environment_domains plan -var-file config/${CONFIG}.tfvars.json

domains-apply: domains-init ## Terraform apply for DNS environment domains. Usage: make development domains-apply
	terraform -chdir=terraform/domains/environment_domains apply -var-file config/${CONFIG}.tfvars.json ${AUTO_APPROVE}

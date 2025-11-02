# Shared Infrastructure

Repository for provisioning infrastructure shared among microservices.


## Repository Structure

- [`scripts/`](./scripts/): Contains utility scripts for managing infrastructure.
  - [`init-remote-backend.sh`](./scripts/init-remote-backend.sh): Script to initialize remote state backend for Terraform. Further details are provided in the [Remote State Initialization](#remote-state-initialization) section below.
- [`infra/`](./infra/): The main directory containing Terraform configurations for shared infrastructure.


## Prerequisites

To work with this repository, ensure you have the following tools installed:
- [Terraform](https://developer.hashicorp.com/terraform/install) for managing cloud infrastructure,
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for interacting with Azure resources. Make sure you are logged in using `az login`.


## Shared Infrastructure

The resources defined in this repository are intended to be shared among multiple microservices. Currently, the following resources are provisioned:
- TODO: List shared resources here.


## Usage of Provisioned Resources by Microservices

TODO: Describe how microservices can utilize the shared infrastructure resources. Also provide config examples.


## Remote State Initialization

Terraform keeps track of the state of your infrastructure in a state file. To collaborate effectively and ensure consistency, it's best to store this state file remotely, where all team members and CI/CD systems can access it. The [`init-remote-backend.sh`](./scripts/init-remote-backend.sh) script automates the setup of an Azure Storage Account and Container to hold the Terraform state file. It also generates an initial Terraform configuration file with the necessary backend settings.

To use the script, follow the steps below:
1. Make sure you are logged into the Azure CLI and have the correct subscription selected.
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```
2. Set the `RESOURCE_GROUP_NAME`, `STORAGE_ACCOUNT_NAME`, and `STORAGE_CONTAINER_NAME` variables in the script as desired.
3. Run the script, optionally specifying an output file name. If no output file is specified, it defaults to `provider.tf`.
   ```bash
   ./scripts/init-remote-backend.sh [output_file.tf]
   ```
4. Upon successful execution, the script will create the required Azure resources and generate a Terraform configuration file with the backend settings.

> **Note:** The remote state only needs to be initialized once, before provisioning infrastructure for the project. This has already been done for this project, so the script does not need to be run again unless you want to set up a new remote backend.

# Shared Infrastructure

Repository for provisioning infrastructure shared among microservices.


## Repository Structure

- [`scripts/`](./scripts/): Contains utility scripts for managing infrastructure.
  - [`init-remote-backend.sh`](./scripts/init-remote-backend.sh): Script to initialize remote state backend for Terraform. Further details are provided in the [Remote State Initialization](#remote-state-initialization) section below.
  - [`manage-services.sh`](./scripts/manage-services.sh): Script to start or stop shared services (AKS and PostgreSQL Flexible Server), as described in the [Starting and Stopping Services](#starting-and-stopping-services) section.
- [`infra/`](./infra/): The main directory containing Terraform configurations for shared infrastructure.


## Prerequisites

To work with this repository, ensure you have the following tools installed:
- [Terraform](https://developer.hashicorp.com/terraform/install) for managing cloud infrastructure,
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for interacting with Azure resources. Make sure you are logged in using `az login`. Also ensure the correct subscription is selected using `az account set --subscription "your-subscription-id"`.


## Provisioned Resources

The resources defined in this repository are intended to be shared among multiple microservices. Currently, the following resources are provisioned:
- [Azure PostgreSQL Flexible Server](./infra/modules/postgres-flexible/): A managed PostgreSQL database service for microservices.
- [Azure Container Registry (ACR)](./infra/modules/acr/): A private container registry for storing Docker images used by microservices.
- [Azure Kubernetes Service (AKS)](./infra/modules/aks/): A managed Kubernetes cluster for deploying and managing containerized microservices. A role is also assigned to allow the AKS cluster to pull images from the ACR.
- [Azure Key Vault](./infra/modules/keyvault/): A secure vault for storing secrets, keys, and certificates that microservices can use to access provisioned resources, such as database credentials.

Details on how microservices can access the provisioned resources are provided in the [Usage of Provisioned Resources by Microservices](#usage-of-provisioned-resources-by-microservices) section below.


## Deploying Resources

To deploy the infrastructure to Azure, follow these steps.
```sh
# Navigate to the infra directory and create terraform.tfvars from the example file
cd infra
cp terraform.tfvars.example terraform.tfvars     # edit as needed

# Perform Terraform operations
terraform init
terraform plan    # review planned changes to the infrastructure
terraform apply
```


## Preparing the Kubernetes Cluster

After provisioning the AKS cluster, it needs to be further prepared to be ready for deploying microservices. This includes
- creating a namespace for the microservices, and
- installing the NGINX Ingress Controller.

This is done using the [`prepare-cluster.sh`](./scripts/prepare-cluster.sh) script:
```sh
./scripts/prepare-cluster.sh
```


## Starting and Stopping Services

To save costs when the shared services are not needed, you can start or stop the AKS cluster and PostgreSQL Flexible Server using the [`manage-services.sh`](./scripts/manage-services.sh) script. The script accepts a single argument: `start` or `stop`.
```sh
./scripts/manage-services.sh start   # Starts the services
./scripts/manage-services.sh stop    # Stops the services
```


## Usage of Provisioned Resources by Microservices

Individual microservices need to know the infrastructure configuration such as kubernetes cluster name, PostgreSQL server name, and credentials to connect to the database. To securely provide this information to microservices, the repository provisions an Azure Key Vault where all necessary configuration details are stored as secrets. The name of the Key Vault can be found in the Terraform outputs (after the infrastructure is provisioned) as follows:
```sh
cd infra # navigate to the infra directory
terraform output keyvault_name
```

The name of the Key Vault is the *only* piece of information that microservices need to access the configuration of the shared resources. The microservices can then use the Azure SDK or Azure CLI to retrieve the necessary values from the Key Vault at runtime.
```sh
az keyvault secret show \
   --vault-name <keyvault_name> \
   --name <secret_name>
```

The secrets stored in the Key Vault are shown below.
| **Secret Name**     | **Description**                                                   |
| ------------------- | ----------------------------------------------------------------- |
| `rg-name`           | Name of the Azure Resource Group used for all deployed resources. |
| `acr-login-server`  | Login server URL of the Azure Container Registry (ACR).           |
| `pg-name`           | Name of the PostgreSQL server instance.                           |
| `pg-fqdn`           | Fully Qualified Domain Name (FQDN) of the PostgreSQL server.      |
| `pg-admin-username` | PostgreSQL administrator username.                                |
| `pg-admin-password` | PostgreSQL administrator password.                                |
| `aks-kube-config`   | Base64-encoded kubeconfig for accessing the AKS cluster.          |
| `aks-name`          | Name of the AKS cluster.                                          |


## Remote State Initialization

> **Note:** The remote state only needs to be initialized once, before provisioning infrastructure for the project. This has already been done for this project, so the script does not need to be run again unless you want to set up a new remote backend.

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

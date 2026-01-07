# Shared Infrastructure

Repository for provisioning infrastructure shared among microservices.


## Repository Structure

- [`scripts/`](./scripts/): Contains utility scripts for managing infrastructure.
  - [`init-remote-backend.sh`](./scripts/init-remote-backend.sh): Script to initialize remote state backend for Terraform. Further details are provided in the [Remote State Initialization](#remote-state-initialization) section below.
  - [`manage-services.sh`](./scripts/manage-services.sh): Script to start or stop services (AKS and PostgreSQL Flexible Server), as described in the [Starting and Stopping Services](#starting-and-stopping-services) section.
  - [`configure-github-repo.sh`](./scripts/configure-github-repo.sh): Script to create *prod* and *dev* secrets in a GitHub repository for accessing provisioned resources, such as from a CI/CD pipeline.
- [`infra/`](./infra/): The main directory containing Terraform configuration. It is organized into:
  - [`modules/`](./infra/modules/): Reusable Terraform modules for different resources such as PostgreSQL, ACR, AKS, and Key Vault.
  - [`environments/`](./infra/environments/): Environment-specific Terraform configurations for `shared`, `dev`, and `prod` environments. The `shared` environment provisions the ACR, while `dev` and `prod` environments provision their own AKS clusters, PostgreSQL databases, and Key Vaults.


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

The infrastructure is organized into separate directories for each environment:
- `infra/environments/shared/`: ACR (Azure Container Registry) shared by all environments.
- `infra/environments/dev/`: Dev environment (AKS, PostgreSQL, Key Vault).
- `infra/environments/prod/`: Prod environment (AKS, PostgreSQL, Key Vault.)

To provision the resources for a specific environment <env>, navigate to the corresponding directory and run the Terraform commands. Note that the `shared` environment should be provisioned first to create the ACR before provisioning `dev` and `prod` environments.
```sh
cd infra/environments/<env>   # Replace <env> with 'shared', 'dev', or 'prod'
terraform init
terraform plan
terraform apply
```

> The `terraform apply` command also prepares the cluster after provisioning resources. It creates the namespace, sets database secrets, installs the NGINX Ingress controller, and deploys Keycloak using Helm.


## Keycloak (Identity Provider)

As part of cluster preparation during `terraform apply`, Keycloak is deployed to the AKS cluster in each environment. To access the Keycloak admin console, follow the steps below. These steps are needed since we do not have a domain name.

1. Navigate to the Terraform environment for which you want to set up Keycloak console access
```sh
cd infra/environments/<env>   # Replace <env> with 'dev' or 'prod'
```
2. Retrieve the Ingress external IP, Keycloak hostname, and admin password
```sh
INGRESS_IP=$(terraform output -raw k8s_ingress_ip)
KEYCLOAK_HOSTNAME=$(terraform output -raw k8s_keycloak_hostname)
KEYCLOAK_ADMIN_PASSWORD=$(terraform output -raw k8s_keycloak_admin_password)
```
3. Add the following entry to your local `/etc/hosts` file (or `/Windows/System32/drivers/etc/hosts`) to map the Keycloak hostname to the Ingress IP
```<INGRESS_IP>   <KEYCLOAK_HOSTNAME>```
4. Access the Keycloak admin console in your web browser at `http://<KEYCLOAK_HOSTNAME>/auth/admin/` using the following credentials:
   - Username: `admin`
   - Password: `<KEYCLOAK_ADMIN_PASSWORD>`


## Starting and Stopping Services

To save costs, you can start or stop AKS and PostgreSQL Flexible Server for a specific environment  when they are not in use. Use the [`manage-services.sh`](./scripts/manage-services.sh) script to manage the services.
```sh
# Starts or stops services for the specified environment <env> ('dev' or 'prod')
./scripts/manage-services.sh <env> start # Start the services
./scripts/manage-services.sh <env> stop  # Stop the services
```


## Usage of Provisioned Resources by Microservices

Each environment (dev/prod) provisions its own Azure Key Vault containing all necessary configuration details. To obtain the Key Vault name for a specific environment, run:
```sh
cd infra/environments/<env>  # Replace <env> with 'dev' or 'prod'
terraform output keyvault_name
```

Microservices can retrieve secrets from the Key Vault at runtime:
```sh
az keyvault secret show \
   --vault-name <keyvault_name> \
   --name <secret_name>
```

The secrets stored in each environment's Key Vault are shown in the table below.
| **Secret Name**     | **Description**                                                   |
| ------------------- | ----------------------------------------------------------------- |
| `rg-name`           | Name of the Azure Resource Group for this environment.            |
| `acr-login-server`  | Login server URL of the shared Azure Container Registry (ACR).    |
| `pg-url`            | Connection string URL for the PostgreSQL Flexible Server. Formatted as `postgresql://<username>:<password>@<fqdn>:5432` |
| `pg-name`           | Name of the PostgreSQL server instance for this environment.      |
| `pg-fqdn`           | Fully Qualified Domain Name (FQDN) of the PostgreSQL server.      |
| `pg-admin-username` | PostgreSQL administrator username.                                |
| `pg-admin-password` | PostgreSQL administrator password.                                |
| `aks-kube-config`   | Base64-encoded kubeconfig for accessing the AKS cluster.          |
| `aks-name`          | Name of the AKS cluster for this environment.                     |
| `gh-identity-client-id` | Client ID of the Managed Identity for GitHub Actions authentication. |
| `gh-identity-tenant-id` | Tenant ID of the Managed Identity for GitHub Actions authentication. |


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

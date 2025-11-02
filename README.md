# Shared Infrastructure

Repository for provisioning infrastructure shared among microservices.


## Repository Structure

- [`init-remote-state/`](./init-remote-state/): Initializes remote storage in Azure for storing Terraform state files, which is necessary before deploying any other infrastructure. More information can be found in the [Remote State Initialization](#remote-state-initialization) section below.


## Prerequisites

To work with this repository, ensure you have the following tools installed:
- [Terraform](https://developer.hashicorp.com/terraform/install) for managing cloud infrastructure,
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for interacting with Azure resources. Make sure you are logged in using `az login`.


## Remote State Initialization

Terraform keeps track of the state of your infrastructure in a state file. To collaborate effectively and ensure consistency, it's best to store this state file remotely, where all team members and CI/CD systems can access it. The [`init-remote-state/`](./init-remote-state/) directory contains the necessary Terraform configuration to set up this remote state storage in Azure.


To initialize the remote state storage, follow these steps.
```sh
cd init-remote-state
terraform init
terraform apply
```

> **Note:** This initialization only has to be performed once, before deploying any other infrastructure. These steps will most likely not need to be repeated for this project. Nonetheless, they are documented here for completeness.


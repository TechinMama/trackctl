# Terraform Infrastructure

This folder provisions Azure infrastructure for the Athena backend.

## Provisioned resources

- Resource Group
- Azure Container Registry (ACR)
- Azure Container Apps Environment + Backend App
- Azure Database for PostgreSQL Flexible Server + DB
- Azure Service Bus Namespace + Queue
- Azure Key Vault (RBAC enabled, purge protection enabled)
- Log Analytics + Application Insights

## Usage

```bash
cd infra/terraform
terraform init
terraform plan -var-file=envs/dev/dev.tfvars
terraform apply -var-file=envs/dev/dev.tfvars
```

## Notes

- Set `postgres_admin_password` via secure secret injection (for example, TF_VAR_postgres_admin_password in CI).
- Container App is configured with managed identity and ACR pull assignment.
- Fill in `container_image` with your pushed backend image before apply.

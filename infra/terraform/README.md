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

# Production profile
terraform plan -var-file=envs/prod/prod.tfvars
terraform apply -var-file=envs/prod/prod.tfvars
```

## Notes

- Set `postgres_admin_password` via secure secret injection (for example, TF_VAR_postgres_admin_password in CI).
- Container App is configured with managed identity and ACR pull assignment.
- Fill in `container_image` with your pushed backend image before apply.

## CI authentication prerequisites

`terraform plan` against the AzureRM provider requires authenticated Azure access. Before enabling the CI plan step for real deployments, configure GitHub Actions with Azure federation or a service principal.

Recommended path: GitHub OIDC with `azure/login`.

Required GitHub Actions configuration:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TF_VAR_postgres_admin_password`

Required workflow capability:

- `permissions: id-token: write`

Once those are configured, add an Azure login step before `terraform plan` so the AzureRM provider can resolve the tenant and subscription context.

## Cost-efficient dev profile

The dev tfvars example is optimized for low traffic:

- Container Apps scales to zero (`container_min_replicas = 0`)
- ACR uses `Basic` SKU
- Service Bus uses `Basic` SKU
- Log Analytics retention is reduced to 7 days

This keeps early costs lower while preserving secure defaults such as Key Vault purge protection and ACR anonymous pull disabled.

## Production profile

Use `envs/prod/prod.tfvars.example` as your production starting point. It keeps predictable baseline capacity (`min_replicas = 1`) and uses Standard SKUs where production resilience and throughput matter.

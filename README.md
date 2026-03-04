Terraform workspace for `static-site-poc`.

Run the following in the `infra/terraform/static-site-poc` directory:

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

This workspace contains modules:
- `static_site` — Storage account (static website)
- `cosmos` — CosmosDB Table API (serverless)
- `function` — Azure Function (Python) with deployment placeholder
\n+The deployment uses the storage account primary web endpoint for public hosting; DNS/custom domain automation has been removed from this example.

Fill `terraform.tfvars` or pass variables at runtime.

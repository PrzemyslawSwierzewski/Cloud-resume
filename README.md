Terraform workspace for `static-site-poc`.

Run the following in the `infra/terraform/static-site-poc` directory:

```bash
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```

This workspace contains modules:
- `static_site` — Storage account (static website) + CDN endpoint
- `cosmos` — CosmosDB Table API (serverless)
- `function` — Azure Function (Python) with deployment placeholder
- `dns` — DNS zone and records for the custom domain

Fill `terraform.tfvars` or pass variables at runtime.

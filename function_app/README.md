Deployment notes for the Azure Function (Python)

1. This function uses `DefaultAzureCredential` and expects the Function App to
   have a system-assigned managed identity. Use the identity to grant access to
   CosmosDB Table API (Data Plane) via role assignment or RBAC where supported.

2. Set these application settings on the Function App (do NOT commit secrets):
   - `TABLE_ACCOUNT_URL` = https://<cosmos-account>.table.cosmos.azure.com
   - `TABLE_NAME` = visitors

3. To deploy the function code (example using `zip` deploy):

```bash
cd infra/terraform/static-site-poc/function_app
pip install -r requirements.txt -t .
zip -r ../functionapp.zip .

# Use Azure CLI to deploy (replace names):
az functionapp deployment source config-zip --resource-group <rg> --name <function-app-name> --src ../functionapp.zip
```

4. Grant the Function App managed identity appropriate data-plane access to the
   Cosmos Table resource (example with role assignment):

```bash
# Assign 'Cosmos DB Built-in Data Contributor' to the function's principal
az role assignment create --assignee <principalId> --role "Cosmos DB Built-in Data Contributor" --scope $(az cosmosdb show -g <rg> -n <cosmosname> --query id -o tsv)
```

5. Test the function by calling its HTTP trigger URL; it will return a JSON
   object with `visitor_count`.

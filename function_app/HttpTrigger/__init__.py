import logging
import os
import json
import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.data.tables import TableClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    """Simple visitor counter using CosmosDB Table API (via Azure Tables SDK).

    This function expects the Function App to run with a system-assigned
    managed identity which has data-plane access to the Cosmos Table resource.
    """
    logging.info('HTTP trigger received a request.')

    table_name = os.environ.get('TABLE_NAME', 'visitors')
    account_url = os.environ.get('TABLE_ACCOUNT_URL')
    if not account_url:
        return func.HttpResponse(json.dumps({"error": "TABLE_ACCOUNT_URL not set"}), status_code=500)

    credential = DefaultAzureCredential()
    client = TableClient(endpoint=account_url, table_name=table_name, credential=credential)

    # Ensure table exists
    try:
        client.create_table()
    except Exception:
        pass

    partition_key = "site"
    row_key = "visitor_count"

    try:
        entity = client.get_entity(partition_key=partition_key, row_key=row_key)
        count = int(entity.get('count', 0)) + 1
        entity['count'] = count
        client.update_entity(entity=entity, mode='Merge')
    except Exception:
        # First-time create
        count = 1
        client.create_entity({'PartitionKey': partition_key, 'RowKey': row_key, 'count': count})

    return func.HttpResponse(json.dumps({"visitor_count": count}), mimetype="application/json")

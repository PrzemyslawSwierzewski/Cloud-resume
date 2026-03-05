import json
import os
import logging
from azure.data.tables import TableServiceClient, TableTransactionError
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Safe access to env variable
    STORAGE_CONN_STRING = os.environ.get("STORAGE_CONN_STRING")
    if not STORAGE_CONN_STRING:
        logging.error("STORAGE_CONN_STRING is not set")
        return func.HttpResponse(
            "Server misconfiguration",
            status_code=500
        )

    table_name = "VisitorCounter"
    partition_key = "resume"
    row_key = "views"

    try:
        table_service = TableServiceClient.from_connection_string(STORAGE_CONN_STRING)
        table_client = table_service.get_table_client(table_name)

        try:
            entity = table_client.get_entity(partition_key=partition_key, row_key=row_key)
            count = entity.get("Count", 0) + 1
            entity["Count"] = count
            table_client.update_entity(entity, mode="Replace")
        except Exception:
            # First-time visitor
            count = 1
            entity = {"PartitionKey": partition_key, "RowKey": row_key, "Count": count}
            table_client.create_entity(entity)

        return func.HttpResponse(
            json.dumps({"visitor_count": count}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Table access error: {e}")
        return func.HttpResponse(
            "Internal server error",
            status_code=500
        )
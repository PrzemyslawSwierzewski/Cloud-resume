import json
import os
import logging
from azure.data.tables import TableServiceClient, UpdateMode
from azure.core.exceptions import ResourceNotFoundError
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("HTTP trigger function started.")

    STORAGE_CONN_STRING = os.environ.get("STORAGE_CONN_STRING")
    if not STORAGE_CONN_STRING:
        return func.HttpResponse("STORAGE_CONN_STRING is missing.", status_code=500)

    table_name = "visitors"
    partition_key = "resume"
    row_key = "views"

    try:
        table_service = TableServiceClient.from_connection_string(STORAGE_CONN_STRING)
        table_client = table_service.get_table_client(table_name)

        try:
            entity = table_client.get_entity(partition_key=partition_key, row_key=row_key)
            count = entity.get("Count", 0) + 1
            entity["Count"] = count
            table_client.update_entity(entity, mode=UpdateMode.REPLACE)
        except ResourceNotFoundError:
            count = 1
            entity = {"PartitionKey": partition_key, "RowKey": row_key, "Count": count}
            table_client.create_entity(entity)

        return func.HttpResponse(
            json.dumps({"visitor_count": count}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        return func.HttpResponse(f"Internal server error: {e}", status_code=500)
    
@app.route(route="visitor_read")
def visitor_read(req: func.HttpRequest) -> func.HttpResponse:
    STORAGE_CONN_STRING = os.environ["STORAGE_CONN_STRING"]
    table_service = TableServiceClient.from_connection_string(STORAGE_CONN_STRING)
    table_client = table_service.get_table_client("visitors")

    partition_key = "resume"
    row_key = "views"

    try:
        entity = table_client.get_entity(partition_key=partition_key, row_key=row_key)
        count = entity.get("Count", 0)
    except Exception:
        count = 0

    return func.HttpResponse(json.dumps({"visitor_count": count}), status_code=200, mimetype="application/json")
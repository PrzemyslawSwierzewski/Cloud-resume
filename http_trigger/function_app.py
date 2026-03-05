import json
import os
import logging
from azure.data.tables import TableServiceClient, UpdateMode
from azure.core.exceptions import ResourceNotFoundError, ResourceModifiedError
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def http_trigger(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("HTTP trigger function started.")

    STORAGE_CONN_STRING = os.environ.get("STORAGE_CONN_STRING")
    table_name = "visitors"
    partition_key = "resume"
    row_key = "views"

    table_service = TableServiceClient.from_connection_string(STORAGE_CONN_STRING)
    table_client = table_service.get_table_client(table_name)

    while True:
        try:
            try:
                entity = table_client.get_entity(partition_key, row_key)

                entity["Count"] = entity.get("Count", 0) + 1

                table_client.update_entity(
                    entity,
                    mode=UpdateMode.REPLACE
                )

                count = entity["Count"]

            except ResourceNotFoundError:
                entity = {
                    "PartitionKey": partition_key,
                    "RowKey": row_key,
                    "Count": 1
                }

                table_client.create_entity(entity)
                count = 1

            break

        except ResourceModifiedError:
            continue

    return func.HttpResponse(
        json.dumps({"visitor_count": count}),
        status_code=200,
        mimetype="application/json"
    )
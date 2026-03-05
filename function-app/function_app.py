import os
import json
from azure.data.tables import TableServiceClient
import azure.functions as func

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="http_trigger")
def main(req: func.HttpRequest) -> func.HttpResponse:
    STORAGE_CONN_STRING = os.environ["STORAGE_CONN_STRING"]
    TABLE_NAME = "VisitorCounter"

    table_service = TableServiceClient.from_connection_string(STORAGE_CONN_STRING)
    table_client = table_service.get_table_client(TABLE_NAME)

    partition_key = "resume"
    row_key = "views"
#deploy it!
    try:
        entity = table_client.get_entity(partition_key=partition_key, row_key=row_key)
        count = entity.get("Count", 0)
        entity["Count"] = count + 1
        table_client.update_entity(entity, mode="Replace")
    except Exception:
        entity = {"PartitionKey": partition_key, "RowKey": row_key, "Count": 1}
        table_client.create_entity(entity)
        count = 1

    return func.HttpResponse(
        json.dumps({"visitor_count": count}),
        status_code=200,
        mimetype="application/json"
    )
import json
import logging
import os

import azure.functions as func
from azure.cosmos import CosmosClient, exceptions


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("GetResumeCounter triggered.")

    # CORS: we'll tighten this later to your Front Door/custom domain.
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    # Preflight support
    if req.method == "OPTIONS":
        return func.HttpResponse("", status_code=204, headers=cors_headers)

    try:
        endpoint = os.environ["COSMOS_ENDPOINT"]
        key = os.environ["COSMOS_KEY"]
        db_name = os.environ["COSMOS_DATABASE"]
        container_name = os.environ["COSMOS_CONTAINER"]

        client = CosmosClient(endpoint, credential=key)
        db = client.get_database_client(db_name)
        container = db.get_container_client(container_name)

        # Container partition key is /id, so partition key for item id="1" is "1"
        try:
            doc = container.read_item(item="1", partition_key="1")
        except exceptions.CosmosResourceNotFoundError:
            doc = {"id": "1", "count": 0}

        doc["count"] = int(doc.get("count", 0)) + 1
        container.upsert_item(doc)

        return func.HttpResponse(
            body=json.dumps({"count": doc["count"]}),
            status_code=200,
            mimetype="application/json",
            headers=cors_headers,
        )

    except Exception as e:
        logging.error(f"Counter API failed: {e}")
        return func.HttpResponse(
            body=json.dumps({"error": "Internal Server Error"}),
            status_code=500,
            mimetype="application/json",
            headers=cors_headers,
        )

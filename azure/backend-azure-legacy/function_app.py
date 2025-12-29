import azure.functions as func
import logging
import json
import os

from azure.cosmos import CosmosClient, exceptions

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@app.function_name(name="GetResumeCounter")
@app.route(route="GetResumeCounter", methods=["GET"])
def GetResumeCounter(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing request for Resume Counter.")

    try:
        # ------------------------------------------------------------------
        # 1. Read environment variables
        # ------------------------------------------------------------------
        COSMOS_ENDPOINT = os.environ["COSMOS_ENDPOINT"]
        COSMOS_KEY = os.environ["COSMOS_KEY"]
        DATABASE_NAME = os.environ["COSMOS_DATABASE"]
        CONTAINER_NAME = os.environ["COSMOS_CONTAINER"]

        # ------------------------------------------------------------------
        # 2. Create Cosmos client
        # ------------------------------------------------------------------
        client = CosmosClient(COSMOS_ENDPOINT, credential=COSMOS_KEY)
        database = client.get_database_client(DATABASE_NAME)
        container = database.get_container_client(CONTAINER_NAME)

        # ------------------------------------------------------------------
        # 3. Read the counter document
        # ------------------------------------------------------------------
        try:
            counter_doc = container.read_item(
                item="1",
                partition_key="1"
            )
        except exceptions.CosmosResourceNotFoundError:
            # If document does not exist, initialize it
            counter_doc = {
                "id": "1",
                "count": 0
            }

        # ------------------------------------------------------------------
        # 4. Increment the counter
        # ------------------------------------------------------------------
        count = counter_doc.get("count", 0) + 1
        counter_doc["count"] = count

        # ------------------------------------------------------------------
        # 5. Upsert the document
        # ------------------------------------------------------------------
        container.upsert_item(counter_doc)

        # ------------------------------------------------------------------
        # 6. Return response
        # ------------------------------------------------------------------
        return func.HttpResponse(
            body=json.dumps({"count": count}),
            status_code=200,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f"Error processing request: {str(e)}")

        return func.HttpResponse(
            body=json.dumps({"error": "Internal Server Error"}),
            status_code=500,
            mimetype="application/json"
        )

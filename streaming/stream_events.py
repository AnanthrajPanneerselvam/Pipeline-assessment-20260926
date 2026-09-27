from google.cloud import bigquery
from datetime import datetime, timezone
import time


# BigQuery configuration
PROJECT_ID = "assessment-28596"
DATASET_ID = "ga4_obfuscated_sample_ecommerce"
TABLE_ID = "streaming_events"
client = bigquery.Client(project=PROJECT_ID)
table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"


# Sample events
events = [
    {
        "event_id": "EVT001",
        "event_name": "page_view",
        "user_pseudo_id": "stream_user_001",
        "source": "google",
        "medium": "organic",
        "revenue": 0.0
    },
    {
        "event_id": "EVT002",
        "event_name": "page_view",
        "user_pseudo_id": "stream_user_002",
        "source": "google",
        "medium": "cpc",
        "revenue": 0.0
    },
    {
        "event_id": "EVT003",
        "event_name": "view_item",
        "user_pseudo_id": "stream_user_003",
        "source": "facebook",
        "medium": "social",
        "revenue": 0.0
    },
    {
        "event_id": "EVT004",
        "event_name": "purchase",
        "user_pseudo_id": "stream_user_001",
        "source": "google",
        "medium": "organic",
        "revenue": 49.99
    },
    {
        "event_id": "EVT005",
        "event_name": "purchase",
        "user_pseudo_id": "stream_user_002",
        "source": "google",
        "medium": "cpc",
        "revenue": 79.99
    },
    {
        "event_id": "EVT006",
        "event_name": "add_to_cart",
        "user_pseudo_id": "stream_user_004",
        "source": "newsletter",
        "medium": "email",
        "revenue": 0.0
    },
    {
        "event_id": "EVT007",
        "event_name": "page_view",
        "user_pseudo_id": "stream_user_005",
        "source": "(direct)",
        "medium": "(none)",
        "revenue": 0.0
    },
    {
        "event_id": "EVT008",
        "event_name": "purchase",
        "user_pseudo_id": "stream_user_005",
        "source": "(direct)",
        "medium": "(none)",
        "revenue": 29.99
    },
    {
        "event_id": "EVT003",
        "event_name": "view_item",
        "user_pseudo_id": "stream_user_003",
        "source": "facebook",
        "medium": "social",
        "revenue": 0.0
    }
]


# Send events one at a time using a small batch load
for event in events:
    event_row = {
        "event_id": event["event_id"],
        "event_timestamp": datetime.now(timezone.utc).isoformat(),
        "event_name": event["event_name"],
        "user_pseudo_id": event["user_pseudo_id"],
        "source": event["source"],
        "medium": event["medium"],
        "revenue": event["revenue"],
        "ingested_at": datetime.now(timezone.utc).isoformat()
    }
    # Load one event into BigQuery
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND
    )
    load_job = client.load_table_from_json(
        [event_row],
        table_ref,
        job_config=job_config
    )
    load_job.result()
    print(
        f"Loaded event: {event_row['event_name']} "
        f"| user={event_row['user_pseudo_id']} "
        f"| source={event_row['source']} "
        f"| medium={event_row['medium']}"
    )
    # Wait 2 seconds before the next event
    time.sleep(2)
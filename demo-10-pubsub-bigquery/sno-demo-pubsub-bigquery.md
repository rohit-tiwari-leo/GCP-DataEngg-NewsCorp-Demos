# sno-demo-pubsub-bigquery.md
## Demo 10 — Pub/Sub → BigQuery direct ingestion (75 minutes)

### Outcome
Create a topic, raw table, BigQuery subscription, publish synthetic events, and prove they land. This lab uses direct BigQuery subscription; Dataflow is an architecture comparison only.

### Before you start
You need a billing-enabled project, `gcloud` and `bq`, Pub/Sub/BigQuery create permissions, and permission to grant dataset IAM. Set the real project ID everywhere. Use synthetic data only.

### Step 1 — Authenticate and verify project
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
gcloud config get-value project
```
Replace `YOUR_PROJECT_ID`. Confirm it is the correct training project.

### Step 2 — Enable APIs and create datasets/topic
From the pack root:
```bash
export PROJECT_ID="$(gcloud config get-value project)"
export REGION=us-central1
bash shared/create_resources.sh
```
Expected: `esports_raw`, `esports_curated`, and `esports-stream` exist. If permission denied, stop and request admin support; do not grant Owner/Editor.

### Step 3 — Create the destination table
```bash
bq mk --table "${PROJECT_ID}:esports_raw.raw_events" demo-10-pubsub-bigquery/schema_raw_events.json
```
If it already exists, inspect it with `bq show --schema --format=prettyjson "${PROJECT_ID}:esports_raw.raw_events"`. Required columns are event_id, event_ts, match_id, player_id, event_type, score, region, sequence.

### Step 4 — Grant the Pub/Sub service agent dataset access
```bash
PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
echo "service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com"
```
Ask an authorized administrator to grant that service agent BigQuery Data Editor on `esports_raw`. One possible command, if supported by the installed CLI and policy:
```bash
bq add-iam-policy-binding --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com" --role="roles/bigquery.dataEditor" "${PROJECT_ID}:esports_raw"
```
Otherwise use BigQuery dataset Sharing → Add principal. Verify current Google Cloud guidance for service-agent requirements.

### Step 5 — Create the BigQuery subscription
```bash
gcloud pubsub subscriptions create esports-bq-sub --topic=esports-stream --bigquery-table="${PROJECT_ID}.esports_raw.raw_events" --use-table-schema --write-metadata
```
If a flag is rejected, run `gcloud pubsub subscriptions create --help` and follow current official BigQuery subscription docs. Do not proceed until the subscription shows the intended destination table.

### Step 6 — Install publisher dependency
```bash
python -m venv .venv
# macOS/Linux: source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
pip install google-cloud-pubsub
```

### Step 7 — Publish 50 events
```bash
python shared/generate_events.py --project "$PROJECT_ID" --topic esports-stream --match-id match-apac-final-04 --count 50 --interval 0.05
```
Expected: published message IDs and event IDs print in the terminal.

### Step 8 — Verify ingestion in BigQuery
Wait 60–120 seconds and run, replacing the project ID:
```sql
SELECT COUNT(*) AS rows_landed, COUNT(DISTINCT event_id) AS distinct_ids,
       MIN(event_ts) AS first_event, MAX(event_ts) AS last_event
FROM `YOUR_PROJECT_ID.esports_raw.raw_events`;
```
Expected: `rows_landed > 0`. Duplicate counts may be equal in this small test; downstream dedupe is still required for at-least-once delivery.

### Step 9 — Publish a known score update
```bash
python shared/generate_events.py --project "$PROJECT_ID" --topic esports-stream --match-id match-apac-final-04 --count 1 --score 2000 --player-id player-valkyrie-99 --interval 0
```
Rerun the SQL query after the subscription processes it.

### Step 10 — Explain trade-offs
Direct subscription is suitable for compatible records needing little in-flight transformation. Use Dataflow when you need parsing/enrichment, event-time windows, watermarks, or multi-stream joins. Do not claim a DLQ is configured unless you explicitly configure and test it.

### Troubleshooting
- No rows: check subscription destination, table schema, service-agent IAM, and subscription errors.
- Publisher permission denied: request Pub/Sub Publisher on topic.
- ADC error: rerun `gcloud auth application-default login`.
- Schema mismatch: compare payload fields/types with destination schema.

### Checkpoint
Show topic, subscription destination, BigQuery row count, and a newly published event. Do not continue until rows exist.

# GCP Data Engineering Day 3 — Guided Demo Pack

This pack follows the uploaded 64-slide master deck and uses one synthetic eSports telemetry scenario across all modules. Follow the `sno-demo-*.md` files in numeric order.

## Run of show: 11 AM–7 PM
- 11:00–12:15 Demo 10: Pub/Sub → BigQuery
- 12:15–12:30 break
- 12:30–1:30 Demo 11: BigQuery curation and ground truth
- 1:30–2:45 Demo 12: Advanced ADK + BigQuery tool (10-minute recap only)
- 2:45–3:15 lunch/break
- 3:15–4:15 Demo 13: Cloud Run deployment
- 4:15–5:15 Demo 14: Model Armor
- 5:15–5:30 break
- 5:30–7:00 Demo 15: capstone

## Explicit prerequisites — do not assume these are already done
1. Google Cloud project with billing enabled; correct project ID; approved region.
2. `gcloud`, `bq`, Python 3.11 recommended; browser signed into same account.
3. Permissions to enable APIs and create Pub/Sub, BigQuery, service accounts, Artifact Registry and Cloud Run resources. If you cannot grant IAM, ask the project admin; never grant Owner/Editor as a workaround.
4. Vertex AI model access and quota in the chosen region.
5. Model Armor access and a supported integration path. A Cloud Run URL is **not automatically** protected by Model Armor.
6. Synthetic data only; do not use customer/participant data.

## Defaults used in every file
- Region: `us-central1` (change only to an organization-approved region)
- Pub/Sub topic: `esports-stream`
- Raw table: `PROJECT_ID.esports_raw.raw_events`
- Curated view: `PROJECT_ID.esports_curated.v_match_telemetry`
- Sample match: `match-apac-final-04`
- Sample player: `player-valkyrie-99`

## Order
1. `demo-10-pubsub-bigquery/sno-demo-pubsub-bigquery.md`
2. `demo-11-bigquery-curation/sno-demo-bigquery-curation.md`
3. `demo-12-adk-agent/sno-demo-adk-bigquery-tool.md`
4. `demo-13-cloud-run/sno-demo-cloud-run-deployment.md`
5. `demo-14-model-armor/sno-demo-model-armor.md`
6. `demo-15-capstone/sno-demo-capstone-esports-agent.md`

Official references: https://cloud.google.com/pubsub/docs/bigquery · https://cloud.google.com/pubsub/docs/ordering · https://google.github.io/adk-docs/ · https://cloud.google.com/run/docs · https://cloud.google.com/security/products/model-armor

ADK APIs, Model Armor features, console labels, and IAM requirements evolve. Validate against current official docs before class; the instructions explicitly flag steps that depend on your project or tenant.

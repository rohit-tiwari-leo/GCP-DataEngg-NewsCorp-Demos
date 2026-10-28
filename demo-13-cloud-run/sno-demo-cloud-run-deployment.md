# sno-demo-cloud-run-deployment.md
## Demo 13 — Package and deploy the ADK agent to Cloud Run (60 minutes)

### Outcome
Deploy the working ADK agent in a container with a dedicated runtime service account. Cloud Run is the executable path for this lab; Agent Engine and GKE are comparison options.

### Prerequisites
Demo 12 works locally. Permissions to create Artifact Registry repo, build/push images, create service accounts, grant scoped IAM, and deploy Cloud Run. If you cannot grant IAM, ask the project admin. Never use Owner/Editor as a shortcut.

### Step 1 — Copy files
Copy `demo-12-adk-agent/agent.py` and its `requirements.txt` into this directory. Do not copy `.env`, ADC files, service-account keys, or secrets into the image.

### Step 2 — Set variables
```bash
export PROJECT_ID=YOUR_PROJECT_ID
export REGION=us-central1
export SERVICE=esports-adk-agent
export REPO=esports-agents
export RUNTIME_SA=esports-agent-runtime
gcloud config set project "$PROJECT_ID"
```

### Step 3 — Enable services and create repository
```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com
gcloud artifacts repositories create "$REPO" --repository-format=docker --location="$REGION" --description="Training ADK agent images"
```
If the repo exists, verify location and format.

### Step 4 — Create runtime identity
```bash
gcloud iam service-accounts create "$RUNTIME_SA" --display-name="eSports ADK runtime"
export RUNTIME_SA_EMAIL="${RUNTIME_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
echo "$RUNTIME_SA_EMAIL"
```
If it exists, verify the account rather than creating another.

### Step 5 — Grant minimum IAM
Ask the administrator to grant the runtime identity scoped BigQuery Data Viewer on the curated dataset, BigQuery Job User at project scope, approved Vertex AI model invocation permissions, and Logging Writer if required. Verify exact roles/scopes for the environment. Never grant project Editor/Owner.

### Step 6 — Build image
```bash
gcloud builds submit --tag "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE}:v1"
```
If build fails, resolve the dependency/import error first. ADK API server commands may differ by version; validate `adk api_server --help` locally before building.

### Step 7 — Deploy authenticated Cloud Run service
```bash
gcloud run deploy "$SERVICE" \
 --image="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${SERVICE}:v1" \
 --region="$REGION" --service-account="$RUNTIME_SA_EMAIL" \
 --set-env-vars="GOOGLE_CLOUD_PROJECT=${PROJECT_ID},GOOGLE_CLOUD_LOCATION=${REGION},GOOGLE_GENAI_USE_VERTEXAI=TRUE,BQ_CURATED_DATASET=esports_curated,BQ_CURATED_VIEW=v_match_telemetry,GEMINI_MODEL=gemini-2.5-flash" \
 --no-allow-unauthenticated
```

### Step 8 — Verify endpoint/API routes
```bash
SERVICE_URL="$(gcloud run services describe "$SERVICE" --region="$REGION" --format='value(status.url)')"
echo "$SERVICE_URL"
TOKEN="$(gcloud auth print-identity-token)"
curl -i -H "Authorization: Bearer ${TOKEN}" "${SERVICE_URL}/docs"
```
This checks connectivity only. ADK endpoint routes vary by version. Inspect `/docs` or the installed server's OpenAPI schema and use the documented endpoint; do not assume `/chat` is valid.

### Step 9 — Inspect logs
```bash
gcloud run services logs read "$SERVICE" --region="$REGION" --limit=50
```
Check startup, model access, and tool invocation. Avoid logging full prompts or result rows.

### Step 10 — Verify least privilege
Ask a known match question through the correct API endpoint and an unknown match question. Confirm the runtime identity cannot read unrelated datasets. Tighten IAM if it can.

### Timebox fallback
If build/IAM consumes more than 20 minutes, use a pre-deployed trainer endpoint if available. State clearly what participants executed versus observed.

### Checkpoint
Authenticated Cloud Run service uses a dedicated runtime identity and returns a grounded BigQuery answer.

# sno-demo-adk-bigquery-tool.md
## Demo 12 — Advanced ADK agent with a governed BigQuery tool (75 minutes)

### Outcome
Run a local ADK agent using a read-only, parameterized BigQuery tool. ADK recap is strictly 10 minutes; do not build Hello World.

### Prerequisites
Demo 11 completed, Python 3.11 recommended, ADC configured, Vertex AI model access, and BigQuery permissions to query the curated view and create jobs. ADK APIs evolve: use the official docs for your installed version if an import or CLI differs.

### Step 1 — Ten-minute terminology recap
Only review agent, tool, session/state, and runner. Then move to control-plane/execution-plane/data-plane boundaries, tool safety, evaluation, and failure modes.

### Step 2 — Authenticate and set environment
```bash
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT=YOUR_PROJECT_ID
export GOOGLE_CLOUD_LOCATION=us-central1
export GOOGLE_GENAI_USE_VERTEXAI=TRUE
export BQ_CURATED_DATASET=esports_curated
export BQ_CURATED_VIEW=v_match_telemetry
```
PowerShell syntax: `$env:GOOGLE_CLOUD_PROJECT="YOUR_PROJECT_ID"` etc.

### Step 3 — Install dependencies
From this folder:
```bash
python -m venv .venv
# macOS/Linux: source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```
If the pinned version is unavailable or your lab mandates another release, choose an approved version and check the current official ADK quickstart. Do not mix SDK examples from different releases.

### Step 4 — Validate BigQuery before calling Gemini
```bash
bq query --use_legacy_sql=false 'SELECT COUNT(*) n FROM `YOUR_PROJECT_ID.esports_curated.v_match_telemetry`'
```
If this fails, fix project/dataset/IAM first.

### Step 5 — Review `agent.py` line by line
Explain input validation, fixed view name, scalar query parameters, max bytes billed, query timeout, normalized errors, source/freshness metadata. The agent must not accept arbitrary SQL from the user.

### Step 6 — Run the ADK web UI
```bash
adk web
```
Run from this directory. Open the local URL printed by the CLI. Try:
- `Who is leading match-apac-final-04?`
- `Show the top three players in match-apac-final-04.`
- `Who is leading match-unknown-99?`
- `Who is winning?`
Expected: grounded answers for known match, no records for unknown match, clarification for missing match ID. If the command differs, run `adk --help` and follow the installed version's official docs.

### Step 7 — Verify against SQL
Repeat Demo 11's current-state query and compare rows. The SQL result is ground truth; the model's prose is not.

### Step 8 — Test boundaries
Try invalid IDs and excessive limits. Confirm values are rejected/clamped and arbitrary SQL cannot be passed through. Inspect local logs without exposing secrets.

### Step 9 — Advanced discussion
Set maximum tool calls, overall wall-clock budget, per-tool timeout, retry policy, session TTL, and versioned golden tests. Explain why repeated identical tool calls should stop rather than amplify spend.

### Troubleshooting
- ADC error: rerun `gcloud auth application-default login`.
- Vertex AI permission/quota: ask admin to verify approved model access and region.
- BigQuery permission error: grant scoped Data Viewer and project-level Job User as approved.
- ADK import/CLI mismatch: use current official docs for installed version.

### Checkpoint
Known match response matches SQL; ambiguous question asks for a match ID; unknown match does not hallucinate data.

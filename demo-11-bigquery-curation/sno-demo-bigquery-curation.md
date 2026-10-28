# sno-demo-bigquery-curation.md
## Demo 11 — Curate streaming data and establish SQL ground truth (60 minutes)

### Outcome
Create a deduplicated view, measure data quality/freshness, and produce deterministic SQL results for the ADK tool.

### Prerequisites
Demo 10 completed; raw table has rows; your identity can create views in `esports_curated` and run BigQuery jobs.

### Step 1 — Verify raw data
Run in BigQuery Studio, replacing the project ID:
```sql
SELECT COUNT(*) AS rows, COUNT(DISTINCT event_id) AS distinct_ids FROM `YOUR_PROJECT_ID.esports_raw.raw_events`;
```
If rows are zero, return to Demo 10.

### Step 2 — Create the view
Open `curate_events.sql`, replace every `YOUR_PROJECT_ID`, and run the statements. If dataset creation is not allowed in your role, create `esports_curated` through the console or ask the admin.

### Step 3 — Inspect duplicates
```sql
SELECT event_id,COUNT(*) n FROM `YOUR_PROJECT_ID.esports_raw.raw_events`
GROUP BY event_id HAVING COUNT(*)>1 ORDER BY n DESC LIMIT 20;
```
Compare raw and curated row counts. The view keeps the latest published row per non-null event_id. This is a teaching policy, not a universal rule.

### Step 4 — Discuss freshness carefully
Run the quality audit. `publish_time - event_ts` measures event-time to Pub/Sub publish-time difference only; it is **not** full end-to-end BigQuery visibility latency. Measure visibility separately by publishing a known event and timing when it becomes queryable.

### Step 5 — Establish the leaderboard truth
Run the final query in `curate_events.sql`. It assumes each SCORE_UPDATE contains the player's latest score. If scores are increments rather than current totals, change the business logic before using the view for answers.

### Step 6 — Capture evidence
Record top three players and the latest event timestamp. These become expected outputs for Demo 12 and the capstone.

### Troubleshooting
- View creation denied: request BigQuery Data Editor on the curated dataset and BigQuery Job User at project scope.
- Invalid timestamps/schema: inspect actual raw values; do not blindly cast.
- No recent events: republish events with Demo 10's publisher.

### Checkpoint
Explain dedupe policy, event-time vs publish-time, and reproduce the leaderboard answer with SQL.

#!/usr/bin/env bash
set -euo pipefail
: "${PROJECT_ID:?Set PROJECT_ID first}"
REGION="${REGION:-us-central1}"
gcloud config set project "$PROJECT_ID"
gcloud services enable pubsub.googleapis.com bigquery.googleapis.com run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com aiplatform.googleapis.com
bq --location="$REGION" mk --dataset "${PROJECT_ID}:esports_raw" || true
bq --location="$REGION" mk --dataset "${PROJECT_ID}:esports_curated" || true
gcloud pubsub topics create esports-stream --message-retention-duration=7d || true
echo 'APIs, datasets and topic verified. Create the raw table and subscription using Demo 10.'

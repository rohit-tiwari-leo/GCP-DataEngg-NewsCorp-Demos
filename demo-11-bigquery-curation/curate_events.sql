-- Replace YOUR_PROJECT_ID before running.
CREATE SCHEMA IF NOT EXISTS `YOUR_PROJECT_ID.esports_curated`;
CREATE OR REPLACE VIEW `YOUR_PROJECT_ID.esports_curated.v_match_telemetry` AS
WITH ranked AS (
 SELECT event_id,event_ts,match_id,player_id,event_type,SAFE_CAST(score AS INT64) score,region,publish_time,
 ROW_NUMBER() OVER(PARTITION BY event_id ORDER BY publish_time DESC) AS row_num
 FROM `YOUR_PROJECT_ID.esports_raw.raw_events` WHERE event_id IS NOT NULL
)
SELECT event_id,event_ts,match_id,player_id,event_type,score,region,publish_time
FROM ranked WHERE row_num=1;

-- Quality and freshness audit
SELECT event_type,COUNT(*) AS rows_after_dedup,COUNT(DISTINCT event_id) AS unique_events,
 ROUND(AVG(TIMESTAMP_DIFF(publish_time,event_ts,SECOND)),2) AS event_to_publish_seconds,
 MAX(event_ts) AS latest_event_ts,MAX(publish_time) AS latest_publish_time
FROM `YOUR_PROJECT_ID.esports_curated.v_match_telemetry`
WHERE event_ts >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(),INTERVAL 24 HOUR)
GROUP BY event_type ORDER BY rows_after_dedup DESC;

-- Current score assumption: each SCORE_UPDATE contains the player's latest score.
SELECT match_id,player_id,score,event_ts,publish_time
FROM `YOUR_PROJECT_ID.esports_curated.v_match_telemetry`
WHERE match_id='match-apac-final-04' AND event_type='SCORE_UPDATE'
QUALIFY ROW_NUMBER() OVER(PARTITION BY match_id,player_id ORDER BY event_ts DESC,publish_time DESC)=1
ORDER BY score DESC;

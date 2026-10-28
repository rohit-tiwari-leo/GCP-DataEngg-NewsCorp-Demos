"""Publish synthetic eSports events to an existing Pub/Sub topic."""
import argparse, json, random, time, uuid
from datetime import datetime, timezone
from google.cloud import pubsub_v1

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--project', required=True); p.add_argument('--topic', default='esports-stream')
    p.add_argument('--match-id', default='match-apac-final-04'); p.add_argument('--count', type=int, default=50)
    p.add_argument('--interval', type=float, default=.05); p.add_argument('--score', type=int)
    p.add_argument('--player-id', default='player-valkyrie-99'); a = p.parse_args()
    pub = pubsub_v1.PublisherClient(); path = pub.topic_path(a.project, a.topic)
    for i in range(a.count):
        e = {'event_id': 'evt-'+uuid.uuid4().hex, 'event_ts': datetime.now(timezone.utc).isoformat(timespec='milliseconds').replace('+00:00','Z'),
             'match_id': a.match_id, 'player_id': a.player_id if a.score is not None else random.choice(['player-valkyrie-99','player-orbit-12','player-nova-07']),
             'event_type': 'SCORE_UPDATE' if a.score is not None else random.choice(['SCORE_UPDATE','PLAYER_ACTION','MATCH_STARTED']),
             'score': a.score if a.score is not None else random.randint(100,2200), 'region':'us-central1', 'sequence':i}
        mid = pub.publish(path, json.dumps(e).encode(), ordering_key=a.match_id).result()
        print(f"published message_id={mid} event_id={e['event_id']} score={e['score']}"); time.sleep(a.interval)
if __name__ == '__main__': main()

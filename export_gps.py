# export_gps.py
from pathlib import Path
import sys
import pandas as pd
from rosbags.highlevel import AnyReader

# Usage: python3 export_gps.py [BAG_DIR] [TOPIC]
bag_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("2025-08-06-metternich_eule")
topic   = sys.argv[2] if len(sys.argv) > 2 else "/lynx/gps/fix"

rows = []

with AnyReader([bag_dir]) as reader:
    # filter only the requested topic
    conns = [c for c in reader.connections if c.topic == topic]
    if not conns:
        raise SystemExit(f"Topic '{topic}' not found. Available: {[c.topic for c in reader.connections]}")
    # iterate messages of that topic
    for conn, ts, raw in reader.messages(connections=conns):
        msg = reader.deserialize(raw, conn.msgtype)
        rows.append({
            "time": ts / 1e9,          # seconds (float) from bag timestamp (ns)
            "latitude": msg.latitude,
            "longitude": msg.longitude,
            "altitude": msg.altitude,
        })

df = pd.DataFrame(rows)
out = bag_dir.with_suffix("").name + "_gps_points.csv"
df.to_csv(out, index=False)
print(f"Wrote {out} with {len(df)} rows from topic {topic}")
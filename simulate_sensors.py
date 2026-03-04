#!/usr/bin/env python3
"""
AquaSense — simulate_sensors.py
================================
Writes realistic, slowly-fluctuating water sensor data to Firebase
every 60 seconds. Simulates 12 wells across Morocco.

Install once:
    pip install requests

Run:
    python3 simulate_sensors.py

Leave it running in the background during your demo.
Press Ctrl+C to stop.
"""

import requests
import json
import time
import random
import math
from datetime import datetime

# ── FIREBASE CONFIG ────────────────────────────────────────────
FIREBASE_URL = "https://aquasense-58345-default-rtdb.europe-west1.firebasedatabase.app"
FIREBASE_SECRET = "02WhgLtHdWcakPUUAgPQUojRoZiMfKS3mF7k91VM"   # ← paste your secret here

# ── UPDATE INTERVAL ────────────────────────────────────────────
UPDATE_EVERY_SECONDS = 60   # change to 10 for faster demo updates

# ── SENSORS — realistic Morocco wells ─────────────────────────
# Each sensor has a "base" level and drifts realistically over time
SENSORS = [
    {
        "id": "well-01",
        "name": "Aït Benhaddou",
        "type": "well",
        "location": "Region Sud, 12km",
        "lat": 31.05, "lon": -7.13,
        "capacity_m3": 400,
        "base_level": 72,      # starting % — will drift slowly
        "drift_speed": 0.3,    # how fast it changes per tick
        "online": True,
        "temp_base": 22.0,
        "ph_base": 7.2,
    },
    {
        "id": "well-02",
        "name": "Puits Marrakech",
        "type": "well",
        "location": "Marrakech-Safi",
        "lat": 31.63, "lon": -7.98,
        "capacity_m3": 400,
        "base_level": 18,
        "drift_speed": 0.4,
        "online": True,
        "temp_base": 24.0,
        "ph_base": 7.4,
    },
    {
        "id": "res-01",
        "name": "Réservoir Fès",
        "type": "reservoir",
        "location": "Fès-Meknès",
        "lat": 34.02, "lon": -5.01,
        "capacity_m3": 800,
        "base_level": 55,
        "drift_speed": 0.2,
        "online": True,
        "temp_base": 18.0,
        "ph_base": 7.0,
    },
    {
        "id": "well-03",
        "name": "Agadir Est",
        "type": "tank",
        "location": "Zone Est, 5km",
        "lat": 30.43, "lon": -9.60,
        "capacity_m3": 350,
        "base_level": 67,
        "drift_speed": 0.35,
        "online": True,
        "temp_base": 22.0,
        "ph_base": 7.2,
    },
    {
        "id": "tank-01",
        "name": "Réservoir Oujda",
        "type": "tank",
        "location": "Oriental",
        "lat": 34.69, "lon": -1.91,
        "capacity_m3": 300,
        "base_level": 67,
        "drift_speed": 0.25,
        "online": True,
        "temp_base": 16.5,
        "ph_base": 7.3,
    },
    {
        "id": "well-04",
        "name": "Reservoir Tiznit",
        "type": "reservoir",
        "location": "Zone Centrale, 8km",
        "lat": 29.70, "lon": -9.73,
        "capacity_m3": 300,
        "base_level": 41,
        "drift_speed": 0.45,
        "online": True,
        "temp_base": 25.0,
        "ph_base": 7.5,
    },
    {
        "id": "well-05",
        "name": "Taroudant Nord",
        "type": "well",
        "location": "Region Nord, 21km",
        "lat": 30.47, "lon": -8.87,
        "capacity_m3": 350,
        "base_level": 18,
        "drift_speed": 0.5,
        "online": True,
        "temp_base": 24.8,
        "ph_base": 7.1,
    },
    {
        "id": "res-02",
        "name": "Réservoir Rabat",
        "type": "reservoir",
        "location": "Rabat-Salé-Kénitra",
        "lat": 34.01, "lon": -6.83,
        "capacity_m3": 600,
        "base_level": 83,
        "drift_speed": 0.15,
        "online": True,
        "temp_base": 18.2,
        "ph_base": 7.0,
    },
    {
        "id": "well-06",
        "name": "Puits Laâyoune",
        "type": "well",
        "location": "Laâyoune-Sakia El Hamra",
        "lat": 27.15, "lon": -13.20,
        "capacity_m3": 200,
        "base_level": 31,
        "drift_speed": 0.4,
        "online": True,
        "temp_base": 28.5,
        "ph_base": 7.6,
    },
    {
        "id": "well-07",
        "name": "Puits Dakhla",
        "type": "well",
        "location": "Dakhla-Oued Ed-Dahab",
        "lat": 23.68, "lon": -15.96,
        "capacity_m3": 180,
        "base_level": 26,
        "drift_speed": 0.35,
        "online": True,
        "temp_base": 27.2,
        "ph_base": 7.4,
    },
    {
        "id": "tank-02",
        "name": "Réservoir Tanger",
        "type": "tank",
        "location": "Tanger-Tétouan",
        "lat": 35.76, "lon": -5.83,
        "capacity_m3": 400,
        "base_level": 78,
        "drift_speed": 0.2,
        "online": True,
        "temp_base": 15.8,
        "ph_base": 6.9,
    },
    {
        "id": "well-08",
        "name": "Drâa-Tafilalet",
        "type": "well",
        "location": "Region SE, 34km",
        "lat": 31.93, "lon": -4.43,
        "capacity_m3": 250,
        "base_level": 34,
        "drift_speed": 0.3,
        "online": False,   # keeps one sensor offline for realism
        "temp_base": 25.9,
        "ph_base": 7.3,
    },
]

# ── RUNTIME STATE ──────────────────────────────────────────────
# Track current levels so they drift continuously
current_levels = {s["id"]: float(s["base_level"]) for s in SENSORS}
tick = 0

def write_sensor(sensor, level_pct, temp, ph):
    """Write one sensor to Firebase REST API."""
    volume = round((level_pct / 100.0) * sensor["capacity_m3"], 1)
    data = {
        "name":        sensor["name"],
        "type":        sensor["type"],
        "location":    sensor["location"],
        "lat":         sensor["lat"],
        "lon":         sensor["lon"],
        "level_pct":   round(level_pct, 1),
        "volume_m3":   volume,
        "capacity_m3": sensor["capacity_m3"],
        "temp_c":      round(temp, 1),
        "ph":          round(ph, 2),
        "online":      sensor["online"],
        "last_ts":     int(time.time()),
    }
    url = f"{FIREBASE_URL}/sensors/{sensor['id']}.json?auth={FIREBASE_SECRET}"
    try:
        r = requests.put(url, json=data, timeout=8)
        return r.status_code == 200
    except Exception as e:
        print(f"  ✗ Network error for {sensor['id']}: {e}")
        return False

def next_level(sensor_id, current, speed):
    """
    Drift the level realistically:
    - Slowly decreases over time (consumption)
    - Occasional small recharge (rain / refill)
    - Never goes below 4% or above 98%
    - Uses sine wave + noise for natural feel
    """
    global tick
    # Base drift: slowly going down (consumption)
    consumption = speed * random.uniform(0.3, 0.7)
    # Noise: small random fluctuation
    noise = random.gauss(0, 0.15)
    # Occasional recharge (10% chance per tick)
    recharge = random.uniform(1.0, 3.5) if random.random() < 0.10 else 0
    new_level = current - consumption + noise + recharge
    return max(4.0, min(98.0, new_level))

def simulate_temp(base_temp):
    """Temperature fluctuates slightly around base."""
    hour = datetime.now().hour
    # Warmer during day, cooler at night
    daily_cycle = math.sin((hour - 6) * math.pi / 12) * 2.5
    return base_temp + daily_cycle + random.gauss(0, 0.3)

def simulate_ph(base_ph):
    """pH stays close to base with tiny fluctuations."""
    return base_ph + random.gauss(0, 0.04)

# ── MAIN LOOP ──────────────────────────────────────────────────
def main():
    global tick
    print("=" * 52)
    print("  💧 AquaSense Sensor Simulator")
    print(f"  Writing to Firebase every {UPDATE_EVERY_SECONDS}s")
    print(f"  Simulating {len(SENSORS)} sensors across Morocco")
    print("  Press Ctrl+C to stop")
    print("=" * 52)

    while True:
        tick += 1
        now = datetime.now().strftime("%H:%M:%S")
        print(f"\n[{now}] Tick #{tick} — updating {len(SENSORS)} sensors...")

        ok_count = 0
        for sensor in SENSORS:
            sid = sensor["id"]

            # Update level
            current_levels[sid] = next_level(sid, current_levels[sid], sensor["drift_speed"])
            level  = current_levels[sid]
            temp   = simulate_temp(sensor["temp_base"])
            ph     = simulate_ph(sensor["ph_base"])

            # Skip writes for offline sensor (but keep its last data)
            if not sensor["online"]:
                print(f"  ⚫ {sensor['name']:25s} OFFLINE (skipping write)")
                continue

            success = write_sensor(sensor, level, temp, ph)
            status  = "🟢" if level > 40 else "🟡" if level > 20 else "🔴"
            mark    = "✓" if success else "✗"
            print(f"  {mark} {status} {sensor['name']:25s} {level:5.1f}% | {temp:.1f}°C | pH {ph:.2f}")
            if success:
                ok_count += 1

        print(f"\n  ✅ {ok_count}/{len([s for s in SENSORS if s['online']])} sensors updated successfully")
        print(f"  ⏳ Next update in {UPDATE_EVERY_SECONDS} seconds...")
        time.sleep(UPDATE_EVERY_SECONDS)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 Simulator stopped.")
"""Purpose: saves everything as .json, and the trials as a .csv table (one row per trial).

Input:  fileBase   file name without extension, e.g. .../Data/LearningPhase/P3_S1_learning
        data       dictionary with everything to save; data['trials'] = list of trials
"""
import csv
import json


def save_data(fileBase, data):
    with open(fileBase + '.json', 'w') as f:
        json.dump(data, f, indent=1)

    rows = data.get('trials', [])
    if rows:
        columns = []
        for row in rows:
            for key in row:
                if key not in columns:
                    columns.append(key)
        with open(fileBase + '.csv', 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=columns)
            writer.writeheader()
            for row in rows:
                writer.writerow(row)

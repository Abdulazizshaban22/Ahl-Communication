#!/usr/bin/env python3

import json, sys


def to_required_schema(src_geojson_path, out_path):
    with open(src_geojson_path, 'r', encoding='utf-8') as f:
        gj = json.load(f)
    features = []
    for ft in gj.get('features', []):
        props = ft.get('properties', {})
        # Try to infer region code/name property names; adjust as needed
        region_code = props.get('ISO_CODE') or props.get('region_iso_code') or props.get('ISO_A2') or props.get('code') or ""
        region_name = props.get('NAME_AR') or props.get('NAME_EN') or props.get('region_name') or props.get('name') or ""
        new_props = {
            "region_iso_code": region_code,
            "region_name": region_name
        }
        features.append({
            "type":"Feature",
            "properties": new_props,
            "geometry": ft.get('geometry')
        })
    out = {"type":"FeatureCollection","name":"ksa_regions","features":features}
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: normalize_ksa_geojson.py <source.geojson> <out.geojson>")
        sys.exit(1)
    to_required_schema(sys.argv[1], sys.argv[2])

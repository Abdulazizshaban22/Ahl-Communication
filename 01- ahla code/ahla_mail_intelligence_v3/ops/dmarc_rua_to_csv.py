#!/usr/bin/env python3
import sys, csv, xml.etree.ElementTree as ET
from pathlib import Path
def parse_rua(file):
    tree = ET.parse(file); root = tree.getroot()
    md = root.find('.//report_metadata')
    org = md.findtext('org_name') if md is not None else ''
    dr = root.find('.//date_range')
    begin = dr.findtext('begin') if dr is not None else ''
    end = dr.findtext('end') if dr is not None else ''
    recs=[]
    for rec in root.findall('.//record'):
        row = rec.find('row'); pol = row.find('policy_evaluated') if row is not None else None
        src_ip = row.findtext('source_ip') if row is not None else ''
        count = row.findtext('count') if row is not None else ''
        disp = pol.findtext('disposition') if pol is not None else ''
        spf = pol.findtext('spf') if pol is not None else ''
        dkim = pol.findtext('dkim') if pol is not None else ''
        header_from = rec.findtext('identifiers/header_from') or ''
        recs.append({"org":org,"begin":begin,"end":end,"source_ip":src_ip,"count":count,"header_from":header_from,"spf":spf,"dkim":dkim,"disposition":disp})
    return recs
def main(path):
    out = sys.stdout; writer=None
    for p in Path(path).glob("*.xml"):
        try:
            for r in parse_rua(p):
                if writer is None:
                    writer = csv.DictWriter(out, fieldnames=list(r.keys())); writer.writeheader()
                writer.writerow(r)
        except Exception as e:
            print(f"# ERROR {p}: {e}", file=sys.stderr)
if __name__ == "__main__":
    if len(sys.argv)<2: print("usage: dmarc_rua_to_csv.py <folder>", file=sys.stderr); sys.exit(1)
    main(sys.argv[1])

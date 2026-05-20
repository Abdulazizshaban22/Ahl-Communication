#!/usr/bin/env python3
import sys, json, csv
from pathlib import Path
def flatten(report):
    org = report.get("organization-name") or ""
    date = report.get("date-range",{})
    begin = date.get("start-datetime") or date.get("start")
    end = date.get("end-datetime") or date.get("end")
    rows=[]
    for pol in report.get("policies",[]):
        pol_domain = pol.get("policy",{}).get("policy-domain") or pol.get("policy",{}).get("policy-string","")
        summary = pol.get("summary") or []
        if isinstance(summary, dict): summary = [summary]
        for s in summary:
            rows.append({
                "org": org, "start": begin, "end": end,
                "policy_domain": pol_domain,
                "result_type": s.get("result-type",""),
                "total_success": s.get("total-successful-session-count",0),
                "additional": json.dumps(s.get("additional-information",{}), ensure_ascii=False)
            })
    return rows
def main(path):
    out = sys.stdout; writer=None
    for p in Path(path).glob("*.json"):
        try:
            data = json.loads(p.read_text())
            for r in flatten(data):
                if writer is None:
                    writer = csv.DictWriter(out, fieldnames=list(r.keys())); writer.writeheader()
                writer.writerow(r)
        except Exception as e:
            print(f"# ERROR {p}: {e}", file=sys.stderr)
if __name__ == "__main__":
    if len(sys.argv)<2: print("usage: tlsrpt_to_csv.py <folder>", file=sys.stderr); sys.exit(1)
    main(sys.argv[1])

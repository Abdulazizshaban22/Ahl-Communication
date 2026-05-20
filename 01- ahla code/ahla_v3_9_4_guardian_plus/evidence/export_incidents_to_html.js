/**
 * Reads incident records (JSON lines) and builds a static HTML evidence report.
 * Usage: node export_incidents_to_html.js incidents.ndjson evidence.html
 */
import fs from 'fs';

const [,, inFile, outFile] = process.argv;
if (!inFile || !outFile) {
  console.error('Usage: node export_incidents_to_html.js incidents.ndjson evidence.html');
  process.exit(1);
}
const lines = fs.readFileSync(inFile, 'utf8').trim().split('\n').map(JSON.parse);

const rows = lines.map(x => `
  <tr>
    <td>${x['@timestamp']||''}</td>
    <td>${x.alarm_name||''}</td>
    <td>${x.state||''}</td>
    <td style="max-width:400px">${(x.reason||'').replace(/</g,'&lt;')}</td>
    <td>${x.region||''}</td>
  </tr>
`).join('');

const html = `<!doctype html>
<html lang="ar" dir="rtl">
<head><meta charset="utf-8"><title>Ahla — PDPL Incident Evidence</title>
<style>
body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin:24px; }
h1 { margin-bottom: 8px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #ddd; padding: 8px; font-size: 13px; }
th { background: #f3f4f6; }
small { color:#4b5563 }
</style>
</head>
<body>
<h1>سجل حوادث حماية البيانات (PDPL)</h1>
<small>التقرير يولّد داخليًا لتجهيز إشعار خلال 72 ساعة عند اللزوم.</small>
<table>
<thead><tr><th>الوقت</th><th>الإنذار</th><th>الحالة</th><th>السبب</th><th>المنطقة</th></tr></thead>
<tbody>${rows}</tbody>
</table>
</body>
</html>`;

fs.writeFileSync(outFile, html);
console.log('written', outFile);

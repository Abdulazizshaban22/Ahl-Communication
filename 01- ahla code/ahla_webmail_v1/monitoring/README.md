# Deliverability Monitoring & Telemetry

- Google Postmaster Tools (UI/API): add ahla.com and IPs, monitor Spam Rate, IP/Domain reputation, Feedback loops.
- TLS-RPT: collect reports at tlsrpt@ahla.com, parse aggregate JSON.
- DMARC RUA/RUF: collect XML aggregates, use an analyzer (e.g. dmarcian, opendmarc tooling).
- MTA dashboards: use Stalwart admin for queues, auth, and TLS stats.

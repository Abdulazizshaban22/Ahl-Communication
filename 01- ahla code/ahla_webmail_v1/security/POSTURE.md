# Security & Brand Posture for @ahla.com

1) DMARC
- Start: v=DMARC1; p=quarantine; rua=mailto:dmarc@ahla.com; ruf=mailto:dmarc@ahla.com; fo=1; adkim=s; aspf=s
- After ~30 days of monitoring move to: p=reject; pct=100
- Spec: RFC 7489 / dmarc.org

2) SPF & DKIM
- SPF: v=spf1 mx -all
- DKIM: selector s1._domainkey with 2048-bit key

3) MTA-STS & TLS-RPT
- _mta-sts TXT: v=STSv1; id=<date>
- policy at https://mta-sts.ahla.com/.well-known/mta-sts.txt
- _smtp._tls TXT: v=TLSRPTv1; rua=mailto:tlsrpt@ahla.com

4) BIMI (Verified Mark Certificate)
- DMARC policy must be quarantine/reject at 100%
- Publish SVG Tiny P/S logo URL + VMC assertion
- Acquire VMC from a CA (Entrust/DigiCert/GlobalSign)

5) Postmaster Monitoring
- Google Postmaster Tools: verify domain + add sending IPs
- Microsoft SNDS / postmaster.live.com for Outlook ecosystem
- Track spam rate, domain & IP reputation, feedback loops.

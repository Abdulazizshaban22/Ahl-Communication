# ACME (Let's Encrypt) options

Option A: Terminate TLS in Stalwart (enable ACME in admin UI for mail.ahla.com).
Option B: Terminate at reverse proxy (NGINX/Traefik) and proxy 443->Stalwart JMAP HTTPS and 465/587 with SNI passthrough.
For MTA-STS site (mta-sts.ahla.com), deploy any web server with automatic cert renewal.

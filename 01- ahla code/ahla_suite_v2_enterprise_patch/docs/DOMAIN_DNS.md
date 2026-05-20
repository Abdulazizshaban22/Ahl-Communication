# Domain Setup for ahla.com

Recommended DNS (A/AAAA for your load balancer/edge):
- auth.ahla.com      -> A YOUR_EDGE_IP
- chat.ahla.com      -> A YOUR_EDGE_IP
- mail.ahla.com      -> A YOUR_EDGE_IP
- drive.ahla.com     -> A YOUR_EDGE_IP
- meet.ahla.com      -> A YOUR_EDGE_IP
- business.ahla.com  -> A YOUR_EDGE_IP
- turn.ahla.com      -> A TURN_SERVER_PUBLIC_IP
- s3.ahla.com        -> A MINIO_PUBLIC_IP (optional)

TLS Certificates (Let's Encrypt):
- For individual certs: use webroot/standalone per vhost.
- For wildcard `*.ahla.com`: use DNS challenge with your DNS provider plugin.

CoTURN:
- Configure `/etc/turnserver.conf` with realm=ahla.com, server-name=turn.ahla.com and fullchain/privkey paths.
- Open 443/TCP and high UDP/TCP port range 49152-65535 on firewall.


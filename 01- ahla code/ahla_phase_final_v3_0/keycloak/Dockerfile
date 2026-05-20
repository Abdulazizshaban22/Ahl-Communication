FROM quay.io/keycloak/keycloak:24.0.5
WORKDIR /opt/keycloak
COPY realm-export.json /opt/keycloak/data/import/realm-export.json
# Import realm on start
ENTRYPOINT ["/opt/keycloak/bin/kc.sh","start","--import-realm","--hostname-strict=false","--http-enabled=true","--http-port=8080"]

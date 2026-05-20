#!/usr/bin/env bash
set -euo pipefail
CONF=${1:-scripts/workmail_users.json}
ORG=$(jq -r '.organization_id' $CONF)
PASS=$(jq -r '.default_password' $CONF)
COUNT=$(jq '.users|length' $CONF)

echo "OrganizationId: $ORG"
for i in $(seq 0 $((COUNT-1))); do
  NAME=$(jq -r ".users[$i].name" $CONF)
  DISPLAY=$(jq -r ".users[$i].display" $CONF)
  EMAIL=$(jq -r ".users[$i].email" $CONF)
  USERID=$(aws workmail create-user --organization-id "$ORG" --name "$NAME" --display-name "$DISPLAY" --password "$PASS" --query 'UserId' --output text)
  echo "Created user $EMAIL -> $USERID"
  aws workmail register-to-work-mail --organization-id "$ORG" --entity-id "$USERID" --email "$EMAIL" >/dev/null
  echo "Registered mailbox $EMAIL"
done

echo "Done. You can now IMAP login with each email and the temporary password."

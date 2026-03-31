#!/bin/sh
# Creates a Cloudflare CNAME record pointing CLOUDFLARE_DOMAIN to the Railway domain.
# Also updates AFFINE_SERVER_HOST and AFFINE_SERVER_HTTPS.
# Runs once on startup — safe to re-run (updates existing records).

if [ -z "$CLOUDFLARE_TOKEN" ] || [ -z "$CLOUDFLARE_DOMAIN" ]; then
  echo "[dns] No CLOUDFLARE_TOKEN/CLOUDFLARE_DOMAIN set, skipping DNS setup."
  exit 0
fi

RAILWAY_DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-${RAILWAY_STATIC_URL}}"
if [ -z "$RAILWAY_DOMAIN" ]; then
  echo "[dns] No RAILWAY_PUBLIC_DOMAIN found, skipping DNS setup."
  exit 0
fi

# Extract subdomain and zone from CLOUDFLARE_DOMAIN (e.g., affine.example.com)
SUBDOMAIN=$(echo "$CLOUDFLARE_DOMAIN" | cut -d. -f1)
ZONE_NAME=$(echo "$CLOUDFLARE_DOMAIN" | cut -d. -f2-)

echo "[dns] Setting up $CLOUDFLARE_DOMAIN -> $RAILWAY_DOMAIN"

# Get zone ID
ZONE_ID=$(node -e "
const https = require('https');
const req = https.get('https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME', {
  headers: { 'Authorization': 'Bearer $CLOUDFLARE_TOKEN' }
}, res => {
  let d = '';
  res.on('data', c => d += c);
  res.on('end', () => {
    const r = JSON.parse(d);
    if (r.success && r.result.length > 0) console.log(r.result[0].id);
    else { console.error('Zone not found:', r.errors); process.exit(1); }
  });
});
req.on('error', e => { console.error(e); process.exit(1); });
" 2>&1)

if [ -z "$ZONE_ID" ] || echo "$ZONE_ID" | grep -q "not found\|error"; then
  echo "[dns] Failed to get zone ID: $ZONE_ID"
  exit 0
fi

echo "[dns] Zone ID: $ZONE_ID"

# Check if record already exists
EXISTING=$(node -e "
const https = require('https');
const req = https.get('https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$CLOUDFLARE_DOMAIN&type=CNAME', {
  headers: { 'Authorization': 'Bearer $CLOUDFLARE_TOKEN' }
}, res => {
  let d = '';
  res.on('data', c => d += c);
  res.on('end', () => {
    const r = JSON.parse(d);
    if (r.success && r.result.length > 0) console.log(r.result[0].id);
  });
});
" 2>&1)

if [ -n "$EXISTING" ]; then
  echo "[dns] Updating existing CNAME record ($EXISTING)"
  METHOD="PUT"
  URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$EXISTING"
else
  echo "[dns] Creating new CNAME record"
  METHOD="POST"
  URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"
fi

RESULT=$(node -e "
const https = require('https');
const data = JSON.stringify({ type: 'CNAME', name: '$SUBDOMAIN', content: '$RAILWAY_DOMAIN', ttl: 1, proxied: false });
const url = new URL('$URL');
const req = https.request({ hostname: url.hostname, path: url.pathname, method: '$METHOD', headers: {
  'Authorization': 'Bearer $CLOUDFLARE_TOKEN', 'Content-Type': 'application/json', 'Content-Length': data.length
}}, res => {
  let d = '';
  res.on('data', c => d += c);
  res.on('end', () => {
    const r = JSON.parse(d);
    if (r.success) console.log('OK: ' + r.result.name + ' -> ' + r.result.content);
    else console.log('FAIL: ' + JSON.stringify(r.errors));
  });
});
req.write(data);
req.end();
" 2>&1)

echo "[dns] $RESULT"

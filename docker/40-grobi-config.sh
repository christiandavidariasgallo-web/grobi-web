#!/bin/sh
# Genera /usr/share/nginx/html/config.js con la URL del webhook de leads.
# Variable de entorno (Easypanel → servicio web → Environment):
#   LEADS_WEBHOOK_URL=https://<tu-n8n>/webhook/grobi-lead
# Si está vacía o no empieza con https://, el sitio funciona igual pero no envía leads.
set -eu

URL="${LEADS_WEBHOOK_URL:-}"
case "$URL" in
  "" ) echo "grobi: LEADS_WEBHOOK_URL vacía; los leads no se enviarán" ;;
  https://* ) echo "grobi: leads se enviarán al webhook configurado" ;;
  * ) echo "grobi: LEADS_WEBHOOK_URL debe empezar con https://; se ignora" >&2; URL="" ;;
esac

# Escapar barra invertida y comillas para que quede como texto JS válido
ESC=$(printf '%s' "$URL" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
printf 'window.GROBI_CONFIG = { leadsWebhook: "%s" };\n' "$ESC" > /usr/share/nginx/html/config.js

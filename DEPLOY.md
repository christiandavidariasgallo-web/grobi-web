# Publicar la landing de Grobi en getgrobi.com (Easypanel)

## Antes de publicar (bloqueantes)

- [ ] `terminos.html` y `privacidad.html`: poner la **fecha de publicación** (único `[PENDIENTE]` que queda).
- [ ] Revisión de ambos documentos por un abogado.
- [ ] Workflow de n8n creado y probado (paso 2), y su URL en `LEADS_WEBHOOK_URL` (paso 4).

## Qué se despliega

| Archivo | Para qué |
|---|---|
| `Dockerfile` | nginx:1.27-alpine, puerto 80 |
| `docker/nginx.conf` | caché, gzip, redirección www → getgrobi.com |
| `docker/security-headers.conf` | cabeceras de seguridad (incluye CSP) |
| `docker/40-grobi-config.sh` | al arrancar escribe `config.js` con `LEADS_WEBHOOK_URL` |
| `index.html`, `terminos.html`, `privacidad.html`, `legal.css`, `config.js`, `img/` | el sitio |

`.dockerignore` deja fuera todo lo demás (CLAUDE.md, presentaciones, borradores).

## Variables de entorno (Easypanel → servicio `web` → Environment)

| Variable | Valor | Obligatoria |
|---|---|---|
| `LEADS_WEBHOOK_URL` | URL de producción del webhook de n8n, p. ej. `https://<tu-n8n>/webhook/grobi-lead` | No: vacía, el sitio funciona pero no envía leads |

No hay contraseñas en el código. La contraseña del correo vive solo en la credencial SMTP de n8n.

## Pasos

### 1. Subir el código a GitHub (repositorio privado)

```bash
git init
git add .
git commit -m "Landing Grobi lista para Easypanel"
git branch -M main
git remote add origin https://github.com/<tu-usuario>/grobi-web.git
git push -u origin main
```

`.gitignore` deja fuera presentaciones y borradores. Revisa `git status` antes del commit.

### 2. Crear el workflow de leads en n8n (no toca los workflows existentes)

1. n8n → **Credentials → New → SMTP**:
   - Host `smtp.hostinger.com`, puerto `465`, SSL activado.
   - Usuario `david@getgrobi.com` y su contraseña. El alias `contacto@` no tiene contraseña propia.
2. n8n → **Workflows → Import from file** → `docker/n8n-grobi-leads.json`.
3. Abre el nodo **Enviar a contacto@** y elige la credencial SMTP del paso 1.
4. Abre el nodo **Webhook** y copia la **Production URL** (termina en `/webhook/grobi-lead`).
5. **Activa** el workflow (interruptor arriba a la derecha).
6. Prueba desde tu computadora:

   ```bash
   curl -X POST "<Production URL>" -H "Content-Type: application/json" -d "{\"nombre\":\"Prueba\",\"empresa\":\"Demo\",\"resumen\":\"Prueba de envío\"}"
   ```

   Debe llegar un correo a contacto@getgrobi.com.

Si la importación marca error en un nodo (cambia entre versiones de n8n), crea los dos nodos a mano:

- **Webhook:** POST, path `grobi-lead`, Respond: Immediately. En Options, Allowed Origins `https://getgrobi.com,https://www.getgrobi.com`.
- **Send Email:** To `contacto@getgrobi.com`, Subject `Nuevo autodiagnóstico: {{ $json.body.empresa }}`, Text `{{ $json.body.resumen }}`.

### 3. Conectar el servicio `web` de Easypanel a GitHub

Proyecto `grobi` → servicio `web` → **Source**:
- **GitHub**, repositorio `grobi-web`, rama `main`, Build Path `/`.
- **Build:** Dockerfile (ruta `Dockerfile`).

Esto reemplaza el Dockerfile anterior del "Próximamente". No toques el proyecto de n8n.

### 4. Variable de entorno

Servicio `web` → **Environment** → `LEADS_WEBHOOK_URL=<Production URL del paso 2>` → **Save**.

### 5. Dominios

Servicio `web` → **Domains**. Deben existir los dos y apuntar al puerto **80** con HTTPS:
- `getgrobi.com`
- `www.getgrobi.com` (nginx lo redirige a `getgrobi.com`)

### 6. Desplegar y comprobar

1. **Deploy**. En los logs debe aparecer `grobi: leads se enviarán al webhook configurado`.
2. Abre `https://getgrobi.com/config.js`: debe mostrar tu URL de n8n.
3. Haz el autodiagnóstico completo con datos de prueba y verifica que llegue el correo.
4. Revisa en el celular y con el teléfono en modo oscuro.

## Publicar cambios después

Edita, luego `git add . && git commit -m "..." && git push`. Después, en Easypanel, **Deploy** (o activa Auto Deploy en Source).

## Volver atrás

Easypanel → servicio `web` → **Deployments** → elige el anterior → **Redeploy**.

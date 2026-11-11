# Landing de Grobi: sitio estático servido por nginx en el puerto 80 (Easypanel pone el HTTPS).
FROM nginx:1.27-alpine

# Configuración de nginx y cabeceras de seguridad
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY docker/security-headers.conf /etc/nginx/snippets/security-headers.conf

# Al arrancar, genera config.js desde las variables de entorno (LEADS_WEBHOOK_URL).
# El sed quita saltos de línea de Windows por si el archivo se editó en Windows.
COPY docker/40-grobi-config.sh /docker-entrypoint.d/40-grobi-config.sh
RUN sed -i 's/\r$//' /docker-entrypoint.d/40-grobi-config.sh \
 && chmod 755 /docker-entrypoint.d/40-grobi-config.sh

# Solo los archivos públicos del sitio
COPY index.html terminos.html privacidad.html legal.css config.js /usr/share/nginx/html/
COPY img/ /usr/share/nginx/html/img/

EXPOSE 80

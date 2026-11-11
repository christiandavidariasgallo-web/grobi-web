// Configuración en tiempo de ejecución. En Easypanel este archivo se regenera al arrancar el
// contenedor a partir de las variables de entorno (ver docker/40-grobi-config.sh).
// En local se queda vacío: el autodiagnóstico funciona igual, solo no envía el lead.
window.GROBI_CONFIG = { leadsWebhook: "" };

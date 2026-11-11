#!/bin/sh
#
# Quita el tema "Blunify Dark Modern" y las banderas GeoIP de pfSense.
# Devuelve el tema que había antes de instalar (o el de fábrica).
#
#   sh uninstall.sh

set -eu

WWW="/usr/local/www"
FOOT="$WWW/foot.inc"
PREV_FILE="/root/.blunify-theme-previous"
HOOK_MARK="zebes-flags.js"

die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "hay que ejecutarlo como root."
[ -d "$WWW/css" ] && [ -f /etc/version ] || die "esto no parece un pfSense."

# --- 1. Volver al tema anterior si el activo es este ---
PREV="pfSense.css"
if [ -s "$PREV_FILE" ]; then
	CANDIDATE="$(head -n 1 "$PREV_FILE")"
	[ -f "$WWW/css/$CANDIDATE" ] && PREV="$CANDIDATE"
fi
/usr/local/bin/php -r '
	require_once("config.inc");
	$cur = (string) config_get_path("system/webgui/webguicss", "pfSense.css");
	if (strpos($cur, "blunify-dark-modern") !== false) {
		config_set_path("system/webgui/webguicss", $argv[1]);
		write_config("Tema Blunify Dark Modern desinstalado");
		echo "Tema activo: {$argv[1]}\n";
	} else {
		echo "El tema activo ($cur) no es Blunify; no lo cambio.\n";
	}
' "$PREV"

# --- 2. Quitar la línea de foot.inc ---
if grep -q "$HOOK_MARK" "$FOOT"; then
	NEW="$(mktemp /tmp/foot.inc.XXXXXX)"
	grep -v "$HOOK_MARK" "$FOOT" > "$NEW"
	if php -l "$NEW" >/dev/null 2>&1; then
		cat "$NEW" > "$FOOT"
		echo "foot.inc restaurado."
	else
		echo "AVISO: no pude limpiar foot.inc; revísalo a mano." >&2
	fi
	rm -f "$NEW"
fi

# --- 3. Borrar archivos ---
rm -f "$WWW"/css/pfSense-theme-blunify-dark-modern-2.8-v4.9.css
rm -f "$WWW/js/zebes-flags.js"
rm -rf "$WWW/vendor/flag-icons"
rm -f "$PREV_FILE"

echo "Desinstalado. Recarga la página con Ctrl+F5."

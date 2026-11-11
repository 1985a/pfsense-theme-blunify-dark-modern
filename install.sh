#!/bin/sh
#
# Instalador del tema "Blunify Dark Modern" para pfSense CE 2.8.x.
#
#   sh install.sh               instala el tema, las banderas GeoIP y lo activa
#   sh install.sh --no-flags    solo el tema (no toca foot.inc)
#   sh install.sh --no-activate copia los archivos sin cambiar el tema activo
#
# Se puede ejecutar desde una copia del repositorio o directamente:
#   fetch -qo - https://raw.githubusercontent.com/1985a/pfsense-theme-blunify-dark-modern/main/install.sh | sh
#
# Es seguro ejecutarlo varias veces (por ejemplo, tras actualizar pfSense).

set -eu

REPO="1985a/pfsense-theme-blunify-dark-modern"
BRANCH="main"
THEME="pfSense-theme-blunify-dark-modern-2.8-v4.9.css"
WWW="/usr/local/www"
FOOT="$WWW/foot.inc"
FOOT_BAK="/root/foot.inc.bak-blunify"
PREV_FILE="/root/.blunify-theme-previous"
HOOK_MARK="zebes-flags.js"

WITH_FLAGS=1
ACTIVATE=1
for arg in "$@"; do
	case "$arg" in
		--no-flags) WITH_FLAGS=0 ;;
		--no-activate) ACTIVATE=0 ;;
		-h|--help) sed -n '3,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
		*) echo "Opción desconocida: $arg" >&2; exit 2 ;;
	esac
done

die() { echo "ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "hay que ejecutarlo como root."
[ -d "$WWW/css" ] && [ -f /etc/version ] || die "esto no parece un pfSense."

VERSION="$(cat /etc/version)"
case "$VERSION" in
	2.8.*) ;;
	*) echo "AVISO: tema probado en pfSense CE 2.8.x; aquí hay $VERSION. Continúo." >&2 ;;
esac

# --- Origen de los archivos: la carpeta del script o una descarga de GitHub ---
TMP=""
cleanup() { [ -n "$TMP" ] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT INT TERM

SRC="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
if [ -z "$SRC" ] || [ ! -f "$SRC/css/$THEME" ]; then
	TMP="$(mktemp -d /tmp/blunify.XXXXXX)"
	echo "Descargando $REPO ($BRANCH)..."
	fetch -qo "$TMP/repo.tar.gz" "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" \
		|| die "no se pudo descargar el repositorio."
	tar -xzf "$TMP/repo.tar.gz" -C "$TMP" --strip-components 1
	SRC="$TMP"
fi
[ -f "$SRC/css/$THEME" ] || die "no encuentro css/$THEME."

# --- 1. Tema ---
install -m 644 "$SRC/css/$THEME" "$WWW/css/$THEME"
echo "Tema copiado en $WWW/css/$THEME"

# --- 2. Banderas GeoIP (opcional): imágenes, script y una línea en foot.inc ---
if [ "$WITH_FLAGS" -eq 1 ]; then
	mkdir -p "$WWW/vendor/flag-icons"
	cp -R "$SRC/vendor/flag-icons/." "$WWW/vendor/flag-icons/"
	chmod -R a+rX "$WWW/vendor/flag-icons"
	install -m 644 "$SRC/js/zebes-flags.js" "$WWW/js/zebes-flags.js"

	if grep -q "$HOOK_MARK" "$FOOT"; then
		echo "foot.inc ya carga el script de banderas."
	else
		grep -q 'js/pfSenseHelpers.js' "$FOOT" \
			|| die "foot.inc no tiene el formato esperado; usa --no-flags."
		[ -f "$FOOT_BAK" ] || cp -p "$FOOT" "$FOOT_BAK"
		NEW="$(mktemp /tmp/foot.inc.XXXXXX)"
		awk '{ print }
			/js\/pfSenseHelpers.js/ {
				print "\t<script src=\"/js/zebes-flags.js?v=<?=filemtime(\x27/usr/local/www/js/zebes-flags.js\x27)?>\"></script><!-- blunify: banderas GeoIP -->"
			}' "$FOOT" > "$NEW"
		# no se toca foot.inc si el resultado no es PHP válido con una línea más
		if php -l "$NEW" >/dev/null 2>&1 \
			&& [ "$(wc -l < "$NEW")" -eq "$(( $(wc -l < "$FOOT") + 1 ))" ]; then
			cat "$NEW" > "$FOOT"
			rm -f "$NEW"
			echo "Script de banderas enlazado en foot.inc (copia en $FOOT_BAK)."
		else
			rm -f "$NEW"
			die "no pude modificar foot.inc con seguridad; no se ha cambiado."
		fi
	fi
fi

# --- 3. Activar el tema en la configuración ---
if [ "$ACTIVATE" -eq 1 ]; then
	/usr/local/bin/php -r '
		require_once("config.inc");
		$new = $argv[1];
		$old = (string) config_get_path("system/webgui/webguicss", "pfSense.css");
		if ($old !== $new) {
			if (strpos($old, "blunify-dark-modern") === false) {
				file_put_contents($argv[2], $old . "\n");
			}
			config_set_path("system/webgui/webguicss", $new);
			write_config("Tema Blunify Dark Modern activado");
			echo "Tema activo: $new (antes: $old)\n";
		} else {
			echo "El tema ya estaba activo.\n";
		}
	' "$THEME" "$PREV_FILE"
else
	echo "Sin activar: elígelo en System > General Setup > Theme."
fi

echo "Listo. Recarga la página con Ctrl+F5."

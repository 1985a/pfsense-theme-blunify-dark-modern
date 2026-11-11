# Cambios

## 5.0 — 2026-11-11

Adaptación a móvil (solo por debajo de 768 px; el escritorio no cambia).

- Zonas táctiles: iconos de acción, casillas, botones y menú más grandes.
- Campos a 16 px para que iOS no haga zoom al enfocar.
- Pestañas en filas completas; botones de acción agrupados a la derecha.
- Widgets del Dashboard: el texto salta de línea en vez de cortarse.
- Sin el borde claro que Bootstrap pone a las tablas en pantallas pequeñas.

## 4.9 — 2026-11-11

- Banderas en las columnas GeoIP de pfBlockerNG (`js/zebes-flags.js` + flag-icons).
- El corte de palabras largas se limita a la tabla *Reports → Unified*; en las
  demás partía nombres de Feed y redes por la mitad.

## 4.8 — 2026-11-11

- Pestañas en varias filas alineadas a la izquierda (Suricata).
- *pfBlockerNG → Reports → Unified* sin barra horizontal; filas grises retintadas.
- Márgenes del botón del widget Speedtest.

## 4.7 — 2026-11-10

Auditoría de 300 páginas con Chrome sin interfaz; de unos 80 grupos de fallos de
contraste a cero.

- Botones: texto blanco en `a.btn`, azul primario más oscuro, naranja con texto oscuro.
- Pestaña activa, separadores de reglas, "/" entre IP y máscara, etiquetas.
- pfBlockerNG: filas y campos con colores claros en línea.
- Controles nativos (`color-scheme: dark`, casillas, listas múltiples, selector de archivo).
- Foco de teclado visible y `prefers-reduced-motion`.
- Eliminados los selectores `:contains()`, que no son CSS válido y anulaban sus reglas.

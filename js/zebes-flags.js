/*
 * zebes-flags.js — añadido local (no es parte de pfSense).
 * En las tablas con una columna "GeoIP" cambia el código de país de dos letras
 * por su bandera; el código queda como texto alternativo y al pasar el ratón.
 * Banderas: flag-icons (MIT) en /vendor/flag-icons/4x3/.
 * Se carga desde foot.inc; una actualización de pfSense quita esa línea.
 */
(function () {
  'use strict';
  var DIR = '/vendor/flag-icons/4x3/';
  var CODE = /^[A-Z]{2}$/;

  function geoColumns(table) {
    var head = table.tHead && table.tHead.rows[0];
    var cols = [];
    if (!head) { return cols; }
    for (var i = 0; i < head.cells.length; i++) {
      if (/^GeoIP/i.test(head.cells[i].textContent.trim())) { cols.push(i); }
    }
    return cols;
  }

  function flagCell(td) {
    var node = td.firstChild;
    while (node && node.nodeType === 3 && !node.nodeValue.trim()) { node = node.nextSibling; }
    if (!node || node.nodeType !== 3) { return; }
    var code = node.nodeValue.trim();
    if (!CODE.test(code)) { return; }

    var img = document.createElement('img');
    img.className = 'zebes-flag';
    img.src = DIR + code.toLowerCase() + '.svg';
    img.alt = code;
    img.title = code;
    img.width = 24;
    img.height = 18;
    img.loading = 'lazy';
    // código sin bandera (p. ej. reservado): vuelve al texto
    img.onerror = function () { img.replaceWith(document.createTextNode(code)); };
    td.setAttribute('data-value', code); // sortable.js ordena por este valor
    td.replaceChild(img, node);
  }

  function scan() {
    var tables = document.querySelectorAll('table');
    for (var t = 0; t < tables.length; t++) {
      var cols = geoColumns(tables[t]);
      if (!cols.length) { continue; }
      var bodies = tables[t].tBodies;
      for (var b = 0; b < bodies.length; b++) {
        for (var r = 0; r < bodies[b].rows.length; r++) {
          for (var c = 0; c < cols.length; c++) {
            var td = bodies[b].rows[r].cells[cols[c]];
            if (td) { flagCell(td); }
          }
        }
      }
    }
  }

  function start() {
    scan();
    // las tablas de pfBlockerNG se recargan solas: vuelve a pasar tras cada cambio
    var pending = false;
    new MutationObserver(function () {
      if (pending) { return; }
      pending = true;
      requestAnimationFrame(function () { pending = false; scan(); });
    }).observe(document.body, { childList: true, subtree: true });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start);
  } else {
    start();
  }
})();

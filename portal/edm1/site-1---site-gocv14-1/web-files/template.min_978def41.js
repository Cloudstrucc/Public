/*!
 * @title Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * @license wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v14.1.0 - 2023-11-21
 *
 */
!function(e,i,n){"use strict";function o(t){if(!t.content){for(var t=t,e=t.childNodes,n=i.createDocumentFragment();e[0];)n.appendChild(e[0]);t.content=n}}var c="wb-template",a="template",t=n.doc;n.tmplPolyfill=o,t.on("timerpoke.wb wb-init.wb-template",a,function(t){t=n.init(t,c,a);t&&(o(t),n.ready(e(t),c))}),n.add(a)}(jQuery,document,wb);
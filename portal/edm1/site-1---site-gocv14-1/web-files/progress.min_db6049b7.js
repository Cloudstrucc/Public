/*!
 * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v4.0.71 - 2023-11-21
 *
 */
!function(n,a){"use strict";function t(e){var r,a=n(e),t=a.children(".progress, .undef"),s=a.children(".wb-inv"),i=1;if(null!==e.getAttribute("value")){0===t.length&&(t=n("<div class='progress'><div class='progress-bar' role='progressbar'></div></div>"),a.append(t));try{i=parseFloat(e.getAttribute("max"))}catch(e){}i<(e=e.getAttribute("value"))&&(e=i),(r=t.children(".progress-bar")).css("width",e/i*100+"%").attr({"aria-valuemin":0,"aria-valuemax":i,"aria-valuenow":e}),s.detach(),s.appendTo(r)}else 0===t.length&&a.append("<div class='undef'></div>");a.trigger("wb-updated."+d)}var d="wb-progress",s="progress",e=a.doc;e.on("timerpoke.wb wb-init.wb-progress wb-update.wb-progress",s,function(e){var r=e.target;"wb-update"===e.type?e.namespace===d&&e.currentTarget===r&&t(r):(r=e,(r=a.init(r,d,s))&&(t(r),a.ready(n(r),d)))}),a.add(s)}(jQuery,(window,wb));
//# sourceMappingURL=progress.min.js.map
/*!
 * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v4.0.71 - 2023-11-21
 *
 */
!function(d,n,a){"use strict";var c="wb-slider",s="input[type='range']",w=0;a.doc.on("wb-init.wb-slider wb-update.wb-slider",s,function(e){var i,t,r=e.target;if(e.currentTarget===r)switch(e.type){case"wb-init":i=e,(i=a.init(i,c,s))&&(i.id||(i.id="wb-sldr-"+w++),n.fdSlider.createSlider({inp:i,html5Shim:!0}),a.ielt9&&(t=d(i)).on("input change",function(e){t.closest("[class^='wb-'], body").trigger(e)}),a.ready(t,c));break;case"wb-update":e.namespace===c&&(n.fdSlider.updateSlider(r.id),d(r).trigger("wb-updated."+c))}})}(jQuery,window,wb);
//# sourceMappingURL=slider_wrapper.min.js.map
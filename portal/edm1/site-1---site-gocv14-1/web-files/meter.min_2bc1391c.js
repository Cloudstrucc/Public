/*!
 * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v4.0.71 - 2023-11-21
 *
 */
!function(m,a){"use strict";function r(t){var e,a=m(t),r=parseFloat(a.attr("min")||0),l=parseFloat(a.attr("max")||1),n=parseFloat(a.attr("high")),o=parseFloat(a.attr("low")),i=parseFloat(a.attr("optimum")),d=null!==a.attr("value")?parseFloat(a.attr("value")):t.textContent||t.innerText,s=t.children;t.textContent?t.textContent="":t.innerText&&(t.innerText=""),d<r?d=r:l<d&&(d=l),null!==o&&o<r&&a.attr("low",o=r),null!==n&&l<n&&a.attr("high",n=l),i=t.offsetWidth*((d-r)/(l-r)),(e=0===s.length?document.createElement("div"):s[0]).style.width=Math.ceil(i)+"px",0===s.length&&t.appendChild(e),n&&n<=d?a.addClass("meterValueTooHigh"):o&&d<=o?a.addClass("meterValueTooLow"):a.removeClass("meterValueTooHigh meterValueTooLow"),l<=d?a.addClass("meterIsMaxed"):a.removeClass("meterIsMaxed"),a.attr({min:r,max:l,value:d,title:a.attr("title")||d}).trigger("wb-updated."+u)}var u="wb-meter",l="meter",t=a.doc;t.on("timerpoke.wb wb-init.wb-meter wb-update.wb-meter",l,function(t){var e=t.target;"wb-update"===t.type?t.namespace===u&&t.currentTarget===e&&r(e):(e=t,(e=a.init(e,u,l))&&(r(e),a.ready(m(e),u)))}),a.add(l)}(jQuery,(window,wb));
//# sourceMappingURL=meter.min.js.map
/*!
 * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v4.0.71 - 2023-11-21
 *
 */
!function(n,r){"use strict";var e=r.doc,t="#plugin",c=n("#issue");e.on("change",t,function(e){e=e.target.value;n(this).trigger({type:"ajax-fetch.wb",fetch:{url:encodeURI("https://api.github.com/repos/wet-boew/wet-boew/issues?labels=Feature: "+e),dataType:"json"}}),c.get(0).value=""}),e.on("ajax-fetched.wb",t,function(e){var t,a,i=n("#"+c.attr("list")),s=r.ielt10?e.fetch.response.data:e.fetch.response,o=s.length,l="";for(i.empty(),t=0;t!==o;t+=1)l+='<option label="'+(a=s[t]).title+'" value="'+a.title+'"></option>';r.ielt10&&(l="<select>"+l+"</select>"),i.append(l),c.trigger("wb-update.wb-datalist")})}(jQuery,wb);
//# sourceMappingURL=datalist_dynamic.min.js.map
/*!
 * Web Experience Toolkit (WET) / Boîte à outils de l'expérience Web (BOEW)
 * wet-boew.github.io/wet-boew/License-en.html / wet-boew.github.io/wet-boew/Licence-fr.html
 * v4.0.71 - 2023-11-21
 *
 */
!function(l,s){"use strict";function i(e){var t,a;"false"!==d.attr("aria-hidden")?(t=(e=e).id,a=o.hide,w.call(e),p.reInit(e.state),v(),d.addClass("open").attr({"aria-controls":t,"aria-labelledby":t+r,"aria-hidden":"false"}).get(0).focus(),l("#"+s.jqEscape(t+r)).attr("title",a).children(".wb-inv").text(a)):n()}function n(){var e=p.field,t=p.$field,a=o.show+p.labelText;l("#"+s.jqEscape(e.id+r)).attr("title",a.replace("&#32;"," ")).children(".wb-inv").html(a),d.removeClass("open").attr("aria-hidden","true"),t.trigger("setfocus.wb")}var c,o,d,p,t,u="wb-date",f="input[type=date]",h="wb-picker",r="-picker-toggle",b=new Date,e=s.doc,g=s.date.fromDateISO,m={minDate:new Date(1800,0,1),maxDate:new Date(2100,0,1),year:b.getFullYear(),month:b.getMonth(),daysCallback:function(e,t,a,i){var n,r=a,l=this.date;(r=i&&(i.max&&(r=r.filter(":lt("+(i.max+1)+")")),i.min)?r.filter(":gt("+(i.min-1)+")"):r).wrap("<a href='javascript:;' tabindex='-1'></a>"),l&&e===l.getFullYear()&&t===l.getMonth()?(n=a.eq(l.getDate()-1)).parent().attr("aria-selected",!0):n=e===b.getFullYear()&&t===b.getMonth()?a.eq(b.getDate()-1):r.eq(0),n.parent().removeAttr("tabindex")}},w=function(){var e=this.state,t=g(this.getAttribute("min"))||e.minDate,a=g(this.getAttribute("max"))||e.maxDate,i=g(this.value);this.state.minDate=t,this.state.maxDate=a,i&&t<=i&&i<=a?(e.date=i,e.year=i.getFullYear(),e.month=i.getMonth()):e.date=null},v=function(){var e=p.field,t=p.$field.offset();d.attr("style","top:"+(t.top+e.offsetHeight)+"px;left:"+t.left+"px")};e.on("timerpoke.wb wb-init.wb-date",f,function(e){var t,a,i,n,e=s.init(e,u,f),r={};e&&(a=e.id,-1===e.className.indexOf("picker-field"))&&(o||(n=(c=s.i18n)("space").replace("&#32;"," ").replace("&#178;",""),o={show:c("date-show").replace("\\'","'")+n,hide:c("date-hide").replace("\\'","'")+n+n+c("esc-key").replace("\\'","'"),selected:c("date-sel").replace("\\'","'")}),e.className+=" picker-field",n={field:this,$field:l(this),labelText:l("label[for="+s.jqEscape(e.id)+"]").clone().find(".datepicker-format, .error").remove().end().text()},t=g(e.getAttribute("min")),i=g(e.getAttribute("max")),t&&(n.minDate=t),i&&(n.maxDate=i),e.state=l.extend(r,m,n),(t=b>=r.minDate&&b<=r.maxDate?b:r.minDate>b?r.minDate:r.maxDate)&&(r.year=t.getFullYear(),r.month=t.getMonth()),w.call(e),p||(i=e,n=o.hide,(d=l("<div id='"+h+"' class='picker-overlay' role='dialog' tabindex='-1' aria-hidden='true'></div>")).find("a").attr("tabindex","-1"),l("main").after(d),p=s.calendar.create(d,i.state),l("<button type='button' class='picker-close mfp-close overlay-close' title=\""+n+"\">&#xd7;<span class='wb-inv'> "+n+"</span></button>").appendTo(d)),a&&(r=e.id,t=e.state.labelText,i=o.show+t,a="<span class='input-group-btn'><a href='javascript:;' button id='"+r+"-picker-toggle' class='btn btn-default picker-toggle' href='javascript:;' title=\""+i+"\"><span class='glyphicon glyphicon-calendar'></span><span class='wb-inv'>"+i+"</span></a></span>",l("#"+s.jqEscape(r)).wrap("<span class='wb-date-wrap input-group'></span>").after(a),d.slideUp(0)),s.ready(l(e),u))}),e.on("focusout focusin","#"+h+" .wb-clndr",function(e){switch(e.type){case"focusout":t=setTimeout(n,10);break;case"focusin":clearTimeout(t)}}),e.on("keydown","#"+h,function(e){27===e.which&&n()}),e.on("click",".picker-overlay .cal-days a",function(e){var t=e.which,a=p.field;if(!(t&&1!==t||a.disabled||a.readOnly))return a.value=l(e.currentTarget).find("time").attr("datetime"),l(a).trigger("change"),n(),!1}),e.on("click",".picker-toggle",function(e){e.preventDefault();var t,a=e.which;if(!(a&&1!==a||(a=e.currentTarget.id,(t=l("#"+s.jqEscape(a.substring(0,a.indexOf(r)))).get(0)).disabled)||t.readOnly))return i(t),!1}),e.on("click",".picker-close",function(e){var t=e.which;t&&1!==t||(e.stopPropagation?e.stopImmediatePropagation():e.cancelBubble=!0,n())}),e.on("txt-rsz.wb win-rsz-width.wb win-rsz-height.wb",function(){d&&d.hasClass("open")&&v()}),s.add(f)}(jQuery,(window,document,wb));
//# sourceMappingURL=datepicker.min.js.map
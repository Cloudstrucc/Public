!function(c){var u,d,v,y=Object.prototype.hasOwnProperty;c.plot.plugins.push({init:function(g,t){t=t.Canvas,null==u&&(d=t.prototype.getTextInfo,v=t.prototype.addText,u=t.prototype.render),t.prototype.render=function(){if(!g.getOptions().canvas)return u.call(this);var t,e=this.context,i=this._textCache;for(t in e.save(),e.textBaseline="middle",i)if(y.call(i,t)){var n,o=i[t];for(n in o)if(y.call(o,n)){var s,r=o[n],a=!0;for(s in r)if(y.call(r,s)){var l=r[s],h=l.positions,f=l.lines;a&&(e.fillStyle=l.font.color,e.font=l.font.definition,a=!1);for(var p,c=0;p=h[c];c++)if(p.active)for(var d,v=0;d=p.lines[v];v++)e.fillText(f[v].text,d[0],d[1]);else h.splice(c--,1);0==h.length&&delete r[s]}}}e.restore()},t.prototype.getTextInfo=function(t,e,i,n,o){if(!g.getOptions().canvas)return d.call(this,t,e,i,n,o);var s,r;if(e=""+e,n="object"==typeof i?i.style+" "+i.variant+" "+i.weight+" "+i.size+"px "+i.family:i,null==(r=(s=null==(s=(o=null==(o=this._textCache[t])?this._textCache[t]={}:o)[n])?o[n]={}:s)[e])){for(var a=this.context,l=("object"!=typeof i&&((i={lineHeight:(o=c("<div>&nbsp;</div>").css("position","absolute").addClass("string"==typeof i?i:null).appendTo(this.getTextLayer(t))).height(),style:o.css("font-style"),variant:o.css("font-variant"),weight:o.css("font-weight"),family:o.css("font-family"),color:o.css("color")}).size=o.css("line-height",1).height(),o.remove()),n=i.style+" "+i.variant+" "+i.weight+" "+i.size+"px "+i.family,r=s[e]={width:0,height:0,positions:[],lines:[],font:{definition:n,color:i.color}},a.save(),a.font=n,(e+"").replace(/<br ?\/?>|\r\n|\r/g,"\n").split("\n")),h=0;h<l.length;++h){var f=l[h],p=a.measureText(f);r.width=Math.max(p.width,r.width),r.height+=i.lineHeight,r.lines.push({text:f,width:p.width,height:i.lineHeight})}a.restore()}return r},t.prototype.addText=function(t,e,i,n,o,s,r,a,l){if(!g.getOptions().canvas)return v.call(this,t,e,i,n,o,s,r,a,l);var t=this.getTextInfo(t,n,o,s,r),h=t.positions,f=t.lines;i+=t.height/f.length/2,i="middle"==l?Math.round(i-t.height/2):"bottom"==l?Math.round(i-t.height):Math.round(i),window.opera&&window.opera.version().split(".")[0]<12&&(i-=2);for(var p,c=0;p=h[c];c++)if(p.x==e&&p.y==i)return void(p.active=!0);h.push(p={active:!0,lines:[],x:e,y:i});for(var d,c=0;d=f[c];c++)"center"==a?p.lines.push([Math.round(e-d.width/2),i]):"right"==a?p.lines.push([Math.round(e-d.width),i]):p.lines.push([Math.round(e),i]),i+=d.height}},options:{canvas:!0},name:"canvas",version:"1.0"})}(jQuery);
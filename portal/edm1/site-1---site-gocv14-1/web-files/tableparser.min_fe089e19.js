!function(ce,e){"use strict";var Z="wb-tableparser",N="."+Z,he="error"+N,ae="warning"+N;e.doc.on("passiveparse"+N,function(e){if(e.namespace===Z){var F,M,Q,$,q=ce(e.target),z={allParserObj:[],nbDescriptionRow:0},A=[],B=[],G=0,J=0,K=[],U=0,V=!1,W=[],te=!1,X=[],c=[],re=!1,e=q.has("tfoot"),v=!1,Y=!1;if("table"!==q.get(0).nodeName.toLowerCase())q.trigger({type:he,pointer:q,err:1});else if(q.tblparser)q.trigger({type:he,pointer:q,err:2});else{Y=q.hasClass("hassum"),(q.data().tblparser=z).colgroup=A,z.rowgroup||(z.rowgroup=[]),z.lstrowgroup||(z.lstrowgroup=c),z.elem=q,z.uid=G,G+=1,z.colcaption={},z.colcaption.uid=G,G+=1,z.colcaption.elem=void 0,z.colcaption.type=7,z.colcaption.dataset=[],z.colcaption.summaryset=[],z.rowcaption={},z.rowcaption.uid=G,G+=1,z.rowcaption.elem=void 0,z.rowcaption.type=7,z.rowcaption.dataset=[],z.rowcaption.summaryset=[],z.col=[],e&&ce("tfoot",q).appendTo(ce("tbody:last",q).parent()),q.children().each(function(){var e,l,t,r,o,c=ce(this),h=this.nodeName.toLowerCase();"caption"===h?(e=this,z.colcaption.elem=e,z.rowcaption.elem=e,r={colcaption:z.colcaption,rowcaption:z.rowcaption,elem:e},o=[],0!==ce(e).children().length?(ce(e).contents().filter(function(){l||3!==this.nodeType?l||1!==this.nodeType||(l=this):0!==(l=ce(this).text().replace(/^\s+|\s+$/g,"")).length?(l=this,t=!0):l=!1}),ce(e).children().filter(function(){t?o.push(this):t=!0})):l=e,1<o.length?r.description=ce(o):1===o.length&&(r.description=o[0]),l&&(r.caption=l),r.groupZero=z,r.type=1,z.groupheadercell=r,ce(e).data().tblparser=r):"colgroup"===h?oe(this):"thead"===h?(M=this,(0!==W.length||z.row&&0<z.row.length)&&q.trigger({type:ae,pointer:this,err:26}),ce(this).data("tblparser",z),te=!0,ce(this).children().each(function(){"tr"!==this.nodeName.toLowerCase()&&q.trigger({type:ae,pointer:this,err:27}),R(this)}),te=!1):"tbody"===h||"tfoot"===h?("tfoot"===h&&(v=!0),M=this,ee(),c.data().tblparser=F,c.children().each(function(){"tr"!==this.nodeName.toLowerCase()?q.trigger({type:ae,pointer:this,err:27}):R(this)}),_(),ce.each(K,function(){this&&this.spanHeigh&&0<this.spanHeight&&q.trigger({type:ae,pointer:this,err:29})}),K=[],X=[]):"tr"===h?R(this):q.trigger({type:he,pointer:this,err:30})}),z.theadRowStack=W,delete z.colgroupFrame,z.colgrouplevel=z.colgrp,delete z.colgrp;for(var w,m,b,C,k,l,t,r,o,h,a,p,H,P,s,d,i,n,L,g,u,j,y=z,O=y.theadRowStack.length,f=0;f<O;f+=1)for(s=0,C=(a=y.theadRowStack[f]).cell.length;s<C;s+=1)if(!(1!==(o=a.cell[s]).type&&7!==o.type||0<s&&o.uid===a.cell[s-1].uid||0<f&&o.uid===y.theadRowStack[f-1].cell[s].uid)){if(o.header=o.header||[],o.headers=o.headers||[],o.child=o.child||[],o.childs=o.childs||[],0<f){for(d=0,b=y.theadRowStack[f-1].cell[s].header.length;d<b;d+=1)o.headers.push(y.theadRowStack[f-1].cell[s].header[d]),y.theadRowStack[f-1].cell[s].header[d].childs.push(o);o.headers.push(y.theadRowStack[f-1].cell[s]),o.header.push(y.theadRowStack[f-1].cell[s]),y.theadRowStack[f-1].cell[s].child.push(o)}o.descCell&&((o.descCell.header=o).descCell.headers=o)}for(f=0,j=y.row.length;f<j;f+=1){if(u=[],g=[],p=[],n=[],l=[],(a=y.row[f]).headerset&&!a.idsheaderset){for(s=0;s<a.headerset.length;s+=1)u=u.concat(a.headerset[s]);a.idsheaderset=u}if(a.header)for(s=0;s<a.header.length;s+=1)g=g.concat(a.header[s]);for(g=a.idsheaderset.concat(g),s=0;s<a.cell.length;s+=1)if(0===s||0<s&&a.cell[s].uid!==a.cell[s-1].uid){if(l=[],(o=a.cell[s]).header=o.header||[],o.headers=o.headers||[],o.col&&!o.col.dataheader){if(t=[],r=[],(h=o.col).headerLevel)for(i=0,P=h.headerLevel.length;i<P;i+=1)r=r.concat(h.headerLevel[i]);if(h.header)for(i=0,H=h.header.length;i<H;i+=1)t=t.concat(h.header[i]);h.dataheader||(h.dataheader=[]),h.dataheader=h.dataheader.concat(r),h.dataheader=h.dataheader.concat(t)}if(o.col&&o.col.dataheader&&(l=o.col.dataheader),1===o.type){for(o.child=o.child||[],o.childs=o.childs||[],i=0,L=n.length;i<L;i+=1)o.colpos===n[i].colpos+n[i].width&&(0===(k=n[i].child.length)||0<k&&n[i].child[k-1].uid!==o.uid)&&n[i].child.push(o),n[i].childs.push(o);for(i=0;i<a.idsheaderset.length;i+=1)a.idsheaderset[i].childs||(a.idsheaderset[i].childs=[]),a.idsheaderset[i].childs.push(o);o.header=o.header.concat(n),o.headers=o.headers.concat(l).concat(a.idsheaderset).concat(n),n=n.concat(o)}if(2===o.type||3===o.type){if(p=g,o.addcolheaders)for(i=0,w=o.addcolheaders.length;i<w;i+=1)l=l.concat(o.addcolheaders[i]);if(o.addrowheaders)for(i=0,m=o.addrowheaders.length;i<m;i+=1)p=p.concat(o.addrowheaders[i]);o.headers=o.headers.concat(l).concat(p),o.header=o.headers}}}q.trigger("parsecomplete"+N)}}function oe(e,l){var t,r,o,c,h={elem:{},start:0,end:0,col:[],groupZero:z},a=0;if((h.elem=e)&&(ce(e).data().tblparser=h),h.uid=G,G+=1,z.allParserObj.push(h),0!==A.length?h.start=A[A.length-1].end+1:h.start=1,e&&ce("col",e).each(function(){var e=ce(this),l=void 0!==e.attr("span")?parseInt(e.attr("span"),10):1,t={elem:{},start:0,end:0,groupZero:z};t.uid=G,G+=1,z.allParserObj.push(t),t.start=h.start+a,t.end=h.start+a+l-1,t.elem=this,t.groupZero=z,e.data().tblparser=t,h.col.push(t),B.push(t),a+=l}),0===h.col.length){if(e)t=void 0!==ce(e).attr("span")?parseInt(ce(e).attr("span"),10):1;else{if("number"!=typeof l)return void q.trigger({type:he,pointer:q,err:31});t=l}for(a+=t,o=(r=h.start)+a;r!==o;r+=1)(c={start:0,end:0,groupZero:z,elem:void 0}).uid=G,G+=1,z.allParserObj.push(c),c.start=r,c.end=r,h.col.push(c),B.push(c)}h.end=h.start+a-1,A.push(h)}function _(){F.type&&F.level||le(),c.push(F),F={}}function ee(){F&&F.type&&_(),(F={}).elem=M,F.row=[],F.headerlevel=[],F.groupZero=z,F.uid=G,G+=1}function le(e){var l,t,r,o;if(v)F.type=3,F.level=0,X=[];else{if(0!==X.length)for(F&&F.type&&0<F.row.length&&(M={},ee()),F.type=2,l=0,t=(F.row=X).length;l!==t;l+=1)X[l].cell[0].type=7,X[l].cell[0].scope="row",X[l].cell[0].row=X[l],F.headerlevel.push(X[l].cell[0]);if(0===X.length&&0===c.length&&(F.type&&1===F.type&&(M={},ee()),F.type=2,F.level=1),0===X.length&&0<c.length&&!F.type&&A[0]&&(1===A[0].type||!A[0].type&&0<A.length)&&!e?F.type=3:F.type=2,3!==F.type||Y||(F.type=2,F.level=c[c.length-1].level),!F.level)if(0<c.length)if(r=c[c.length-1],2===F.type)if(F.headerlevel.length===r.headerlevel.length)F.level=r.level;else if(F.headerlevel.length<r.headerlevel.length){for(o=F.headerlevel,F.headerlevel=[],l=0;l<r.headerlevel.length-F.headerlevel.length;l+=1)F.headerlevel.push(r.headerlevel[l]);for(l=0;l<o.length;l+=1)F.headerlevel.push(o[l]);F.level=r.level}else F.headerlevel.length>r.headerlevel.length&&(F.level=F.headerlevel.length+1);else if(3===F.type)for(3===r.type?F.level=r.level-1:F.level=r.level,F.level<0&&q.trigger({type:ae,pointer:q,err:12}),l=0;l<r.headerlevel.length;l+=1)r.headerlevel[l].level<F.level&&F.headerlevel.push(r.headerlevel[l]);else F.level="Error, not calculated",q.trigger({type:ae,pointer:q,err:13});else F.level=1+X.length;for(l=0;l<F.headerlevel.length;l+=1)F.headerlevel[l].level=l+1,F.headerlevel[l].rowlevel=F.headerlevel[l].level;X=[],(void 0===F.level||F.level<0)&&q.trigger({type:ae,pointer:F.elem,err:14})}}function R(e){J+=1;var h,a,p,s,l,t,r,o,c,d=1,i="",n=!1,E=ce(e).children(),g={colgroup:[],cell:[],elem:e,rowpos:J};if((ce(e).data().tblparser=g).uid=G,G+=1,(g.groupZero=z).allParserObj.push(g),(h={cell:[],cgsummary:void 0,type:!1}).uid=G,G+=1,z.allParserObj.push(h),a=function(e){h.type||(h.type=1),1!==h.type&&(g.colgroup.push(h),(h={cell:[],type:1}).uid=G,G+=1,z.allParserObj.push(h)),h.cell.push(e),n=e.colpos+e.width-1},p=function(e){h.type||(h.type=2),2!==h.type&&(g.colgroup.push(h),(h={cell:[],type:2}).uid=G,G+=1,z.allParserObj.push(h)),h.cell.push(e)},s=function(){for(var e,l;d<=U&&K[d]&&(l=K[d]).spanHeight&&0<l.spanHeight&&l.colpos===d&&l.height+l.rowpos-l.spanHeight===J;){for("th"===(i=l.elem.nodeName.toLowerCase())?a(l):"td"===i&&p(l),1===l.spanHeight?delete l.spanHeight:--l.spanHeight,e=0;e<l.width;e+=1)g.cell.push(l);d+=l.width}},ce.each(E,function(){var e,l,t,r=ce(this),o=void 0!==r.attr("colspan")?parseInt(r.attr("colspan"),10):1,c=void 0!==r.attr("rowspan")?parseInt(r.attr("rowspan"),10):1;switch(this.nodeName.toLowerCase()){case"th":for(s(),e={rowpos:J,colpos:d,width:o,height:c,data:[],summary:[],elem:this},(r.data().tblparser=e).groupZero=z,e.uid=G,G+=1,z.allParserObj.push(e),a(e),e.parent=h,e.spanHeight=c-1,t=0;t<o;t+=1)g.cell.push(e),K[d+t]=e;d+=e.width;break;case"td":for(s(),l={rowpos:J,colpos:d,width:o,height:c,elem:this},(r.data().tblparser=l).groupZero=z,l.uid=G,G+=1,z.allParserObj.push(l),p(l),l.parent=h,l.spanHeight=c-1,t=0;t<o;t+=1)g.cell.push(l),K[d+t]=l;d+=l.width;break;default:q.trigger({type:ae,pointer:this,err:15})}i=this.nodeName.toLowerCase()}),s(),(U=0===U?g.cell.length:U)!==g.cell.length&&(g.spannedRow=K,q.trigger({type:ae,pointer:g.elem,err:16})),te)W.push(g);else{if(g.colgroup.push(h),"th"===i){if(g.type=1,2===g.colgroup.length&&1===J)if(2===g.colgroup[0].type&&1===g.colgroup[0].cell.length){if(0===ce(g.colgroup[0].cell[0].elem).html().length)return void W.push(g);q.trigger({type:ae,pointer:q,err:17})}else q.trigger({type:ae,pointer:q,err:18});if(1===g.colgroup.length){if(1<g.colgroup[0].cell.length){if(!V)return void W.push(g)}else if(1!==J||g.cell[0].uid===g.cell[g.cell.length-1].uid)return X.push(g),void(V=!0);q.trigger({type:ae,pointer:q,err:18})}1<g.colgroup.length&&1!==J&&q.trigger({type:ae,pointer:q,err:21})}else{if(g.type=2,V=!0,0<X.length&&g.cell[0].uid===g.cell[g.cell.length-1].uid)return g.type=5,g.cell[0].type=5,(g.cell[0].row=g).cell[0].describe||(g.cell[0].describe=[]),X[X.length-1].cell[0].descCell=g.cell[0],g.cell[0].describe.push(X[X.length-1].cell[0]),z.desccell||(z.desccell=[]),void z.desccell.push(g.cell[0]);if((0<X.length||!F.type)&&le(),g.type=F.type,g.level=F.level,A[0]&&n&&A[0].end!==n&&A[0].end===n+1&&(n+=1),g.lastHeadingColPos=n,F.lastHeadingColPos||(F.lastHeadingColPos=n),$=$||n,(g.rowgroup=F).lastHeadingColPos!==n&&(!Q&&F.lastHeadingColPos<n||Q&&Q===n?(ce.each(K,function(){this&&0<this.spanHeight&&q.trigger({type:ae,pointer:this,err:29})}),K=[],X=[],_(),M=void 0,ee(),le(),g.type=F.type):Q&&$===n?(ce.each(K,function(){this&&0<this.spanHeight&&q.trigger({type:ae,pointer:this,err:29})}),K=[],X=[],_(),M=void 0,ee(),le(!0),g.type=F.type,q.trigger({type:ae,pointer:g.elem,err:34})):q.trigger({type:ae,pointer:q,err:32})),F.lastHeadingColPos||(F.lastHeadingColPos=n),3===F.type&&(Q=Q||n),n){for(l=[],t=void 0,r=[],o=0;o<n;o+=1)if("td"===g.cell[o].elem.nodeName.toLowerCase()&&(g.cell[o].type||!g.cell[o-1]||g.cell[o-1].descCell||1!==g.cell[o-1].type||g.cell[o-1].height!==g.cell[o].height||(g.cell[o].type=5,g.cell[o-1].descCell=g.cell[o],g.cell[o].describe||(g.cell[o].describe=[]),g.cell[o].describe.push(g.cell[o-1]),g.desccell||(g.desccell=[]),g.desccell.push(g.cell[o]),z.desccell||(z.desccell=[]),z.desccell.push(g.cell[o]),g.cell[o].scope="row"),g.cell[o].type||r.push(g.cell[o])),"th"===g.cell[o].elem.nodeName.toLowerCase())for(g.cell[o].type=1,g.cell[o].scope="row",t&&t.uid!==g.cell[o].uid&&(t.height>=g.cell[o].height?(t.height===g.cell[o].height&&q.trigger({type:ae,pointer:q,err:23}),t.subheader||(t.subheader=[],t.isgroup=!0),t.subheader.push(g.cell[o]),t=g.cell[o],l.push(g.cell[o])):q.trigger({type:ae,pointer:q,err:24})),t||(t=g.cell[o],l.push(g.cell[o])),c=0;c<r.length;c+=1)r[c].type||g.cell[o].keycell||r[c].height!==g.cell[o].height||(r[c].type=4,g.cell[o].keycell=r[c],g.keycell||(g.keycell=[]),g.keycell.push(r[c]),z.keycell||(z.keycell=[]),z.keycell.push(r[c]),r[c].describe||(r[c].describe=[]),r[c].describe.push(g.cell[o]));ce.each(r,function(){this.type||(q.trigger({type:ae,pointer:q,err:25}),g.errorcell||(g.errorcell=[]),g.errorcell.push(this))}),g.header=l}else(n=0)===A.length&&oe(void 0,U);var u,y,f,v,w,m,b,C,k,H,P,L,j,O,R,Z,N,S,I,T,x=n,D=[];if(!z.colgrouphead&&!re){for(re=!0,x&&0<x?0<A.length&&(1!==A[0].start||A[0].end!==x&&A[0].end!==x+1)&&(q.trigger({type:ae,pointer:q,err:3}),A=[]):x=0,u=0,y=W.length;u!==y;u+=1)for((T=W[u]).type||(T.type=1),f=0,v=T.cell.length;f<v&&((S=W[u].cell[f]).scope="col",!(0===u&&0===f&&0===S.elem.innerHTML.length&&(S.type=6,z.layoutCell||(z.layoutCell=[]),z.layoutCell.push(S),f=S.width-1,v<=f)))&&(N=(Z=W[u+1])?Z.cell[f]:"",S.descCell||"th"!==S.elem.nodeName.toLowerCase()||S.type||!Z||Z.uid===S.uid||!N||N.type||"td"!==N.elem.nodeName.toLowerCase()||N.width!==S.width||1!==N.height||(Z.type=5,N.type=5,N.row=T,S.descCell=N,z.desccell||(z.desccell=[]),z.desccell.push(N),f=S.width-1,!(v<=f)));f+=1)S.type||(S.type=1);for(u=0,y=W.length;u!==y;u+=1)if(5===(T=W[u]).type){for(f=0,v=T.cell.length;f!==v;f+=1)5!==(S=T.cell[f]).type&&6!==S.type&&1===S.height&&q.trigger({type:ae,pointer:S.elem,err:4}),S.uid===W[u-1].cell[f].uid&&--S.height;z.nbDescriptionRow+=1}else D.push(T);if(z.colgrp=[],0<x&&(1===A.length||0===A.length)){for(k=[],(H={start:x+1,end:U,col:[],groupZero:z,elem:void 0,type:2}).uid=G,G+=1,z.allParserObj.push(H),H.start>H.end&&q.trigger({type:ae,pointer:q,err:5}),u=(e=H).start,y=H.end;u<=y;u+=1)(P={start:0,end:0,groupZero:z,elem:void 0}).uid=G,G+=1,z.allParserObj.push(P),z.col||(z.col=[]),k.push(P),P.start=u,P.end=u,(P.groupstruct=H).col.push(P),B.push(P);if(z.colgrp[1]=[],z.colgrp[1].push(z.colcaption),0<x){for((L={start:1,elem:void 0,end:x,col:[],groupZero:z,type:1}).uid=G,G+=1,z.allParserObj.push(L),A.push(L),A.push(e),z.colcaption.dataset=e.col,u=L.start,y=L.end;u<=y;u+=1)(P={start:0,end:0,groupZero:z,elem:void 0}).uid=G,G+=1,z.allParserObj.push(P),z.col||(z.col=[]),z.col.push(P),P.start=u,P.end=u,(P.groupstruct=L).col.push(P),B.push(P);for(u=0,y=k.length;u!==y;u+=1)z.col.push(k[u])}for(0===A.length&&(A.push(e),z.colcaption.dataset=e.col),u=0,y=z.col.length;u!==y;u+=1)for((I=z.col[u]).header=[],f=0,v=D.length;f!==v;f+=1)for(w=I.start,m=I.end;w<=m;w+=1)S=D[f].cell[w-1],(0===f||0<f&&S.uid!==D[f-1].cell[w-1].uid)&&1===S.type&&I.header.push(S)}else H={start:j=0===x?1:A[0].end+1,end:void 0,col:[],row:[],type:2},R=!(O=[]),ce.each(A,function(){var h,e,l,t,a=this;if(R||z.colgrp[0])q.trigger({type:he,pointer:a,err:6});else if(ce.each(a.col,function(){z.col||(z.col=[]),z.col.push(this),this.type=1,this.groupstruct=a}),a.start<j)for(x!==a.end&&q.trigger({type:ae,pointer:a,err:7}),u=0,y=a.col.length;u!==y;u+=1)for((I=a.col[u]).header=[],f=0,v=D.length;f!==v;f+=1)for(w=I.start,m=I.end;w<=m;w+=1)(0===f||0<f&&D[f].cell[w-1].uid!==D[f-1].cell[w-1].uid)&&1===D[f].cell[w-1].type&&I.header.push(D[f].cell[w-1]);else{for(h=void 0,u=0,y=D.length;u!==y;u+=1){if(!(C=D[u].cell[a.end-1])&&a.end>D[u].cell.length){q.trigger({type:ae,pointer:q,err:3});break}C.colpos+C.width-1===a.end&&C.colpos>=a.start&&(!h||u+1<h)&&(h=u+1)}for(u=(h=h||1)-1,y=D.length;u!==y;u+=1)for(b=D[u],f=a.start-1,v=a.end;f!==v;f+=1)if((C=b.cell[f]).colpos<a.start||C.colpos+C.width-1>a.end)return void q.trigger({type:he,pointer:q,err:9});for(u=O.length,y=h-1;u!==y;u+=1){if((C=D[u].cell[a.start-1]).uid!==D[u].cell[a.end-1].uid||C.colpos>a.start||C.colpos+C.width-1<a.end)return void q.trigger({type:he,pointer:q,err:10});(e=C).level=u+1,e.start=e.colpos,e.end=e.colpos+e.width-1,e.type=7,O.push(e),z.virtualColgroup||(z.virtualColgroup=[]),z.virtualColgroup.push(e),z.colgrp[u+1]||(z.colgrp[u+1]=[]),z.colgrp[u+1].push(e)}for(a.header=[],u=h-(2<=h?2:1),y=D.length;u!==y;u+=1)for(f=a.start;f<=a.end;f+=1)D[u].cell[f-1].rowpos===u+1&&(a.header.push(D[u].cell[f-1]),D[u].cell[f-1].colgroup=a),f+=D[u].cell[f-1].width-1;for(l=[],u=0;u<O.length-1;u+=1)l.push(O[u]);for(a.parentHeader=l,O.length<h&&(a.type||(a.type=2,a.level=h),O.push(a),z.colgrp[h]||(z.colgrp[h]=[]),z.colgrp[h].push(a)),t=!1,u=O.length-1;-1!==u;--u)O[u].end<=a.end&&(O[u].level<h&&0<W.length&&(a.type=3),3!==a.type||t||(O[O.length-1].summary=a,t=!0),O.pop());if(Y||(a.type=2),1===h&&z.colgrp[1]&&1<z.colgrp[1].length&&0<W.length){for(u=0;u<z.colgrp[1].length;u+=1)if(3===z.colgrp[1][u].type){a.level=0,z.colgrp[0]||(z.colgrp[0]=[]),z.colgrp[0].push(a),z.colgrp[1].pop(),R=!0;break}Y&&(a.type=3)}1===a.level&&2===a.type&&(a.repheader="caption"),z.col||(z.col=[]),ce.each(a.col,function(){var e,l,t,r=this,o=r.start,c=r.end;for(r.type=a.type,r.level=a.level,r.groupstruct=a,r.header=[],f=h-1;f<D.length;f+=1)for(u=a.start-1;u<a.end;u+=1)t=(l=D[f].cell[u]).colpos,e=l.width-1,(o<=t&&t<=c||t<=o&&c<=t+e||t+e<=o&&c<=t+e)&&(0===(t=r.header.length)||0<t&&r.header[t-1].uid!==l.uid)&&(r.header.push(l),D[f].cell[u].level=a.level)})}}),z.virtualColgroup||(z.virtualColgroup=[]),ce.each(z.virtualColgroup,function(){for(u=this.start-1;u<this.end;u+=1)z.col[u].headerLevel||(z.col[u].headerLevel=[]),z.col[u].headerLevel.push(this)});0<A.length&&0<x&&(z.colgrouphead=A[0],z.colgrouphead.type=1)}for(g.headerset=F.headerlevel||[],0!==n&&(n=A[0].end),g.datacell||(g.datacell=[]),o=n;o<g.cell.length;o+=1){for(c=0===n?0:1;c<A.length;c+=1)A[c].start<=g.cell[o].colpos&&g.cell[o].colpos<=A[c].end&&(3===g.type||3===A[c].type?g.cell[o].type=3:g.cell[o].type=2,3===g.type&&3===A[c].type&&0===ce(g.cell[o].elem).text().length&&(g.cell[o].type=6,z.layoutCell||(z.layoutCell=[]),z.layoutCell.push(g.cell[o])),g.cell[o].collevel=A[c].level,g.datacell.push(g.cell[o])),0;if(0===A.length&&(g.cell[o].type=2,g.datacell.push(g.cell[o])),g.cell[o].rowpos<J&&(g.cell[o].addrowheaders||(g.cell[o].addrowheaders=[]),g.header))for(c=0;c<g.header.length;c+=1)(g.header[c].rowpos===J&&0===g.cell[o].addrowheaders.length||g.header[c].rowpos===J&&g.cell[o].addrowheaders[g.cell[o].addrowheaders.length-1].uid!==g.header[c].uid)&&g.cell[o].addrowheaders.push(g.header[c])}for(z.col||(z.col=[]),o=0;o<z.col.length;o+=1)for(c=z.col[o].start-1;c<z.col[o].end;c+=1)z.col[o].cell||(z.col[o].cell=[]),c>z.col[o].start-1&&z.col[o].cell[z.col[o].cell.length-1].uid===g.cell[c].uid||(g.cell[c]?(z.col[o].cell.push(g.cell[c]),g.cell[c].col||(g.cell[c].col=z.col[o])):q.trigger({type:ae,pointer:q,err:35}));for(o=0;o<g.cell.length;o+=1)if(g.cell[o].row||(g.cell[o].row=g),g.cell[o].rowlevel=F.level,g.cell[o].rowlevelheader=F.headerlevel,g.cell[o].rowgroup=F,0<o&&g.cell[o-1].uid===g.cell[o].uid&&1!==g.cell[o].type&&5!==g.cell[o].type&&g.cell[o].rowpos===J&&g.cell[o].colpos<=o&&(g.cell[o].addcolheaders||(g.cell[o].addcolheaders=[]),z.col[o])&&z.col[o].header)for(c=0;c<z.col[o].header.length;c+=1)z.col[o].header[c].colpos===o+1&&g.cell[o].addcolheaders.push(z.col[o].header[c])}z.row||(z.row=[]),z.row.push(g),F.row.push(g),delete g.colgroup}}})}(jQuery,(window,document,wb));
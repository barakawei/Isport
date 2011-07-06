jQuery.fcbkListSelection=function(elem,width,height,row){var getContent=function(elem,tab){switch(tab){case"all":elem.children("li").show();break;case"selected":elem.children("li:not([addedid])").hide();elem.children("li[addedid]").show();break;case"unselected":elem.children("li[addedid]").hide();elem.children("li:not([addedid])").show();break}};var hiddenCheck=function(obj){switch(curTab()){case"all":elem.children("li").show();break;case"selected":elem.children("li:not([addedid])").hide();elem.children("li[addedid]").show();break;case"unselected":elem.children("li[addedid]").hide();elem.children("li:not([addedid])").show();break}};var addToSelected=function(obj){if(obj.hasClass("itemselected")){$("#view_selected_count").text(parseInt($("#view_selected_count").text(),10)-1);obj.parents("li").removeAttr("addedid");removeValue(obj)}else{$("#view_selected_count").text(parseInt($("#view_selected_count").text(),10)+1);obj.parents("li").attr("addedid","tester");addValue(obj)}hiddenCheck(obj)};var bindEventsOnItems=function(elem){$.each(elem.children("li").children(".fcbklist_item"),function(i,obj){obj=$(obj);if(obj.children("input[checked]").length!=0){addToSelected(obj);obj.toggleClass("itemselected");obj.parents("li").toggleClass("liselected")}obj.click(function(){addToSelected(obj);obj.toggleClass("itemselected");obj.parents("li").toggleClass("liselected")});obj.mouseover(function(){obj.addClass("itemover")});obj.mouseout(function(){$(".itemover").removeClass("itemover")})})};var bindEventsOnTabs=function(elem){$.each($("#selections li"),function(i,obj){obj=$(obj);obj.click(function(){$(".view_on").removeClass("view_on");obj.addClass("view_on");getContent(elem,obj.attr("id").replace("view_",""))})})};var createTabs=function(elem,width){var html='<div id="filters" style="width:'+(parseInt(width,10)+2)+'px;"><ul class="selections" id="selections"><li id="view_all" class="view_on"><a onclick="return false;" href="#">All</a></li><li id="view_selected" class=""><a onclick="return false;" href="#">Selected (<strong id="view_selected_count">0</strong>)</a></li></ul></div>';elem.before(html);elem.before('<div class="clearer"></div>')};var wrapElements=function(elem,width,height,row){elem.children("li").wrapInner('<div class="fcbklist_item"></div>');$(".fcbklist_item").css("height",height+"px");var newwidth=Math.ceil((parseInt(width,10))/parseInt(row,10))-11;$(".fcbklist_item").css("width",newwidth+"px")};var addValue=function(obj,value){var inputid=elem.attr("id")+"_values";if($("#"+inputid).length==0){var input=document.createElement("input");$(input).attr({type:"hidden",name:inputid,id:inputid,value:""});elem.after(input)}else{var input=$("#"+inputid)}var randid="rand_"+randomId();if(!value){value=obj.find("[type=hidden]").val();obj.find("[type=hidden]").attr("randid",randid)}var jsdata=new data(randid,value);var stored=jsToString(jsdata,$(input).val());$(input).val(stored);return input};var jsToString=function(jsdata,json){var string="{";$.each(jsdata,function(i,item){if(i){string+='"'+i+'":"'+item+'",'}});try{eval("json = "+json+";");$.each(json,function(i,item){if(i&&item){string+='"'+i+'":"'+item+'",'}})}catch(e){}string=string.substr(0,(string.length-1));string+="}";return string};var data=function(id,value){try{eval("this."+id+" = value;")}catch(e){}};var removeValue=function(obj){var randid=obj.find("[type=hidden]").attr("randid");var inputid=elem.attr("id")+"_values";if($("#"+inputid).length!=0){try{eval("json = "+$("#"+inputid).val()+";");var string="{";$.each(json,function(i,item){if(i&&item&&i!=randid){string+='"'+i+'":"'+item+'",'}});if(string.length>2){string=string.substr(0,(string.length-1));string+="}"}else{string=""}$("#"+inputid).val(string)}catch(e){}}};var randomId=function(){var chars="0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";var string_length=32;var randomstring="";for(var i=0;i<string_length;i++){var rnum=Math.floor(Math.random()*chars.length);randomstring+=chars.substring(rnum,rnum+1)}return randomstring};var curTab=function(){return $(".view_on").attr("id").replace("view_","")};if(typeof(elem)!="object"){elem=$(elem)}elem.css("width",width+"px");createTabs(elem,width);wrapElements(elem,width,height,row);bindEventsOnTabs(elem);bindEventsOnItems(elem)};function friend_select(){$("#friend_select").empty();$("#friend_select").append('<div class="filter" style="position:relative"> <input id="filter" type="text" style="width:100px;height:16px"></div><ul id="fcbklist"></ul><br><div class="button " style="width: 40px;float:right" id="friend_select_button"><a href="#">ok</a></div>');$("#friend_select_button").button({});var a=$("#fcbklist");$("#friend_select_button").click(function(){var b=[];a.find("li[addedid]").each(function(){b.push(this.id)});var c=b.join(",");friend_selected_callback(c)});$.ajax({type:"get",url:"/people/friend_select",success:function(b){$.each(b.data,function(c){a.append($('<li id="'+b.data[c].person.id+'"><img class="avatar" title="'+b.data[c].person.name+'" alt="'+b.data[c].person.name+'" src="'+b.data[c].person.image_url+'"/><div class="content" style="position: absolute;left: 60px;top: 0">'+b.data[c].person.name+"</div></li>"))});$.fcbkListSelection("#fcbklist","450","50","4");filter_friend(a)}})}function filter_friend(b){var a=b.find("li");$("#filter").keyup(function(){var e=$(this);var f=e.val();if(!f){e.data("lastVal",f);a.show();return}var c=e.data("lastVal");e.data("lastVal",f);if(f===c){return}a.filter(":visible").hide();var d;switch($(".view_on").attr("id").replace("view_","")){case"all":d=a;break;case"selected":d=a.filter("[addedid]");break;case"unselected":d=a.filter(":not([addedid])");break}d.filter(":icontains("+f+")").show()});$.extend($.expr[":"],{icontains:function(e,d,c){return(new RegExp(c[3],"im")).test($(e).text())}})};
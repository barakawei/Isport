$( function(){  
  var show_handle = null;
  var remove_handle = null;
  var ajax_handle = null;


  var show_avatar = function(img,link,avatar_container) { 
    if ($( ".avatar_show",avatar_container ).length == 0){
    var person_id = img.attr( "data_person_id" );
    var url = img.attr( "src" ).replace("small","medium");
    $.post( "/contacts/show_avatar_panel",{ person_id:person_id },function( result ){
      person = result.person.person;
      myself = result.myself;
      var contact;
      if (result.contact.length > 0){
        contact = result.contact[ 0 ].contact;
      }
      avatar_panel = $("<div class ='avatar_show hide overlay'><div data_person_id='"+person.id+"' class='avatar_panel overlay_body'>"
                +"<a href='"+link+"'><img class='person_avatar' src='"+url+"'/></a>"
                +"<div class='person_content'>"
                +"<a href='"+link+"'><div class='name'>"+person.name+"</div></a>"
                +"<div class='action'><div class='follow_button'></div></div>"
                +"</div>"
                +"</div></div>");
      avatar_container.append( avatar_panel ); 


      delete_html = $( "<a href='/contacts/destroy?person_id="+person.id+"' data-method='delete' data-remote='true'><div class='following glass_button' data_id='"+person.id+"'><span>已关注</span></div></a>" );
      post_html = $( "<a href='/contacts?person_id="+person.id+"' data-method='post' data-remote='true'><div class='follow glass_button' data_id='"+person.id+"'><span>关注</span></div></a>" );
      if ( myself ){
        $( ".follow_button",avatar_container ).remove();
      }else{
        if (contact && contact.receiving){
        $( ".follow_button",avatar_container ).append(delete_html);
        }else{
        $( ".follow_button",avatar_container ).append( post_html );
        }  
      }
      

      $( ".avatar_show",avatar_container ).mouseenter(function(  ){
        clearTimeout(remove_handle);
      } ).mouseleave( function(  ){  
         remove_handle = setTimeout(function(){  $(".avatar_show",avatar_container).fadeOut(200); },500);
      } );
    });
    }
  }


  $( ".avatar_container .person_avatar_detail" ).live({
    mouseenter:function(){
    var img = $( this );
    var link = $( this ).closest( "a" ).attr( "href" );
    var avatar_container = img.closest( ".avatar_container" );
    ajax_handle = setTimeout(function(  ){ show_avatar(img,link,avatar_container); },100);
    $( ".avatar_show" ).fadeOut( 200 );
    show_handle = setTimeout(function(){  $(".avatar_show",avatar_container).fadeIn( 500 ); },700);    

  },
    mouseleave:function(){
      clearTimeout(ajax_handle);
      clearTimeout(show_handle);
      var img = $( this );
      avatar_container = img.closest( ".avatar_container" );
      remove_handle = setTimeout(function(){  $(".avatar_show",avatar_container).fadeOut(200); },500);
      },
    click:function(){
      $(".avatar_show",avatar_container).addClass( "hide" );
      clearTimeout(show_handle);
    }
  });
} );


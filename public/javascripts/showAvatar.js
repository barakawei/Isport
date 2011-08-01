$( function(){  
  var show_handle = null;
  var remove_handle = null;

  $( ".avatar_container .person_avatar_detail" ).live({
    mouseenter:function(){
    var img = $( this );
    var link = $( this ).closest( "a" ).attr( "href" );
    var avatar_container = img.closest( ".avatar_container" );
  if ($( ".avatar_show",avatar_container ).length == 0){
    var person_id = img.attr( "data_person_id" );
    var url = img.attr( "src" ).replace("small","medium");
    $.post( "/contacts/show_avatar_panel",{ person_id:person_id },function( result ){
      person = result.person[ 0 ].person;
      myself = result.myself;
      var contact;
      if (result.contact.length > 0){
        contact = result.contact[ 0 ].contact;
      }
      avatar_panel = $("<div class ='avatar_show hide overlay'><div data_person_id='"+person.id+"' class='avatar_panel overlay_body'>"
                +"<a href='"+link+"'><img class='person_avatar' src='"+url+"'/></a>"
                +"<div class='person_content'>"
                +"<a href='"+link+"'><div class='name'>"+person.name+"</div></a>"
                +"<div class='action'><div class='relation_button'></div></div>"
                +"</div>"
                +"</div></div>");
      avatar_container.append( avatar_panel ); 

      delete_html = $( "<span url='/contacts/destroy?person_id="+person.id+"' data-method='delete'> 取消关注</span>" );
      post_html = $( "<span url='/contacts?person_id="+person.id+"' data-method='post'> 关注</span>" );
      if ( myself ){
        $( ".relation_button",avatar_container ).remove();
      }else{
        if (contact && contact.receiving){
        $( ".relation_button",avatar_container ).append(delete_html);
        $( ".relation_button",avatar_container ).addClass( "unfollow" );
        }else{
        $( ".relation_button",avatar_container ).append( post_html );
        $( ".relation_button",avatar_container ).addClass( "follow" );
        }  
      }
      

      $( ".avatar_show",avatar_container ).mouseenter(function(  ){
        clearTimeout(remove_handle);
      } ).mouseleave( function(  ){  
         remove_handle = setTimeout(function(){  $(".avatar_show",avatar_container).fadeOut(200); },500);
      } );


    });
    }
    $( ".avatar_show" ).fadeOut( 200 );
    show_handle = setTimeout(function(){  $(".avatar_show",avatar_container).fadeIn( 500 ); },700);    

  },
    mouseleave:function(){
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

   var lock = 0;
    $( ".relation_button" ).live( "click",function() {
        person_id = $( this ).closest( ".avatar_panel" ).attr( "data_person_id" );
        if( lock == 0 ){  
        lock = 1;
         delete_html = $( "<span url='/contacts/destroy?person_id="+person_id+"' data-method='delete'>- 取消关注</span>" );
        post_html = $( "<span url='/contacts?person_id="+person_id+"' data-method='post'>+ 关注</span>" );
        button = $(this);
        type = $( this ).find( "span" ).attr( "data-method" );
        url = $( this ).find( "span" ).attr( "url" );

        $.ajax( {
          url:url,
          type:type,
          success:function(){
          if( type == 'delete' ){
          button.find( "span" ).remove();
          button.append( post_html );
          button.removeClass( "unfollow" );
          button.addClass( "follow" );
        }else{
          button.find( "span" ).remove();
          button.append( delete_html );
          button.removeClass( "follow" );
          button.addClass( "unfollow" );
        }
          lock = 0;
          }
        } );
        }
  });
} );


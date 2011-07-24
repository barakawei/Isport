  $( '.photos_container img' ).live( "click",function(){
    $("img",$( this).closest( ".photos_container" )).each(function(){
        origin = $( this ).attr( "origin" );
        src = $( this ).attr( "src" );
        if($( this ).hasClass( "block")){
          $( this ).removeClass( "block" );
        }else{
          $( this ).addClass( "block" );
        }
        $( this ).attr("origin",src )
        $(this).attr( "src",origin );
    } );
  });

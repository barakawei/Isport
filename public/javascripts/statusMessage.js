  $( ".replay" ).live( "click",function( ){  
    stream_element = $( this ).closest(".stream_element");
    commentBlock = stream_element.find(".comment_form");
    commentBlock.removeClass( "hide" );    
    commentBlock.find("textarea").focus(); 
    return false;
    }); 

  $("a.toggle_post_comments").live('click', function(  ){
    var toggler = $(this),
        comments = toggler.closest('.stream_element').find('.comments');
    if (comments.hasClass('loaded') && !comments.hasClass('hide')){
      hideComments.apply(toggler);
    }else {
      showComments.apply(toggler);
    } 
    return false;

     });

  function showComments(  ){
    var commentList = this.closest('.stream_element').find('.comments'),
        toggle = this;

    if( commentList.hasClass('loaded') ){
        commentList.removeClass('hide');
        toggle.html("隐藏评论");
    }
    else {
      toggle.append("<img alt='loading' src='/images/ui/ajax-loader.gif' />");
      $.ajax({
        url: this.attr('url'),
        success: function(data){
          toggle.html("隐藏评论");
          commentList.html(data)
                     .addClass('loaded');
        }
      });
    }
    return false;
  }

  function hideComments(  ){ 
    var commentList = this.closest('.stream_element').find('.comments');
    commentList.addClass('hide');
    this.html("显示所有评论");
    return false;
  }

  $( ".comment_form textarea" ).live("focus", function(){ 
    comment_button = $( this ).closest( ".comment_form" ).find( ".comment_button" ); 
    comment_button.removeClass( "hide" );
  });

  $( ".cancle" ).live( "click",function(  ){
    comment_form = $( this ).closest( ".comment_form" );
    comment_form.find( "textarea" ).val( '' );
    if( $( ".comments",comment_form.closest( '.element_body' )).length == 0 ){
      comment_form.addClass( "hide" );
        }else{
    comment_button = comment_form.find( ".comment_button" ); 
    comment_button.addClass( "hide" );
    }
  });  

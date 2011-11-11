var Post = {
  replay: function(){
    $(document).delegate(".replay","click",function( ){  
    stream_element = $( this ).closest(".stream_element");
    commentBlock = stream_element.find(".comment_form");
    commentBlock.removeClass( "hide" );    
    textarea = commentBlock.find("#comment_content");
    textarea.focus(); 
    replay_comment = $( this ).closest(".replay_comment");
    if ( replay_comment.length != 0 ){
      contacts_input = stream_element.find( "#contacts" );
      author_name = $( this ).closest(".comment_content").find( ".from a" ).html();
      author_id = $( this ).closest(".comment").find( ".author_avatar .person_avatar_detail" ).attr("data_person_id");
      Mention.clear();
      content = "回复@"+author_name+": ";
      textarea.val(content); 
      contacts_content = "回复@{"+author_name+";"+author_id+"}";
      contacts_input.val(contacts_content);
      var mention = { visibleStart: 3, 
                      visibleEnd  : 4+author_name.length,
                      mentionString : "{"+author_name+";"+author_id+"}"
                    };
      Mention.autocompletion.mentionList.push(mention);

    }
    return false;
    });
  },
  toggle:function(){
    $(document).delegate("a.toggle_post_comments",'click', function(  ){
    var toggler = $(this),
        comments = toggler.closest('.stream_element').find('.comments');
    if (comments.hasClass('loaded') && !comments.hasClass('hide')){
      Post.hideComments.apply(toggler);
    }else {
      Post.showComments.apply(toggler);
    } 
    return false;
     });
  },
  showComments:function(){
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
  },
  hideComments:function(){
    var commentList = this.closest('.stream_element').find('.comments');
    commentList.addClass('hide');
    this.html("显示所有评论");
    return false;
  },
  cancle:function(){
    $( ".cancle" ).live( "click",function(  ){
    comment_form = $( this ).closest( ".comment_form" );
    comment_form.find( "#comment_content" ).val( '' );
    comment_form.find(".contacts").val("");
    Mention.clear();
    if( $( ".comments",comment_form.closest( '.element_body' )).length == 0 ){
      comment_form.addClass( "hide" );
        }else{
    comment_button = comment_form.find( ".comment_button" ); 
    comment_button.addClass( "hide" );
    }
  });
  },
  rewrite: function(){
    $( ".content[name]" ).live("focus", function(){ 
    if ( $( this ).val() == '' ){
      $( ".content[name]" ).val( '' );
      $(".contacts").val("");
      Mention.clear();
    }
    comment_button = $( this ).closest( ".comment_form" ).find( ".comment_button" ); 
    comment_button.removeClass( "hide" );
  });
  },
  initialize : function() {
    Post.replay();
    Post.toggle();
    Post.cancle();
    Post.rewrite();
  }
};
$(document).ready(function(){
  Post.initialize();
});

  
  

    

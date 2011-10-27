module CommentsHelper
  def comment_toggle(post, commenting_disabled=false)
    if post.comments.size <= 3
      str = link_to "#{t('status_message.hide_comments')}", post_comments_path(post.id), :class => "toggle_post_comments"
    else
      str = link_to "#{t('status_message.show_more_comments', :number => post.comments.size - 3)}", "#",:url => post_comments_path(post.id), :class => "toggle_post_comments"
    end
    str
  end

  def pic_comment_toggle(pic, commenting_disabled=false)
    if pic.comments.size <= 3
      str = link_to "#{t('status_message.hide_comments')}", pic_show_more_comments_path(pic.id), :class => "toggle_post_comments"
    else
      str = link_to "#{t('status_message.show_more_comments', :number => pic.comments.size - 3)}", "#",:url => pic_show_more_comments_path(pic.id), :class => "toggle_post_comments"
    end
    str
  end
  
end

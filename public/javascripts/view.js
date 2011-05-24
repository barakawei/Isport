var View = {
  initialize: function() {
   
       /* User menu */
    $(this.userMenu.selector)
      .click(this.userMenu.click);

    $(document.body)
      .click(this.userMenu.removeFocus);

    jQuery(document).ready(function($) {
      $('a[rel*=facebox]').facebox()
    });
    
  },
   
  userMenu: {
    click: function(evt) {
      $(this).parent().toggleClass("active");
      evt.preventDefault();
    },
    removeFocus: function(evt) {
      var $target = $(evt.target);
      if(!$target.closest("#user_menu").length || ($target.attr('href') != undefined && $target.attr('href') != '#')) {
        $(View.userMenu.selector).parent().removeClass("active");
      }
    },
    selector: "#user_menu li:first-child"
  }
};

 
$(function() {
  View.initialize.apply(View);
});

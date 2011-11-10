(function() {
  var NotificationDropdown = function() {
    var self = this;
    this.start = function() {
      this.badge = $("#notification_badge");
      this.badgeLink = this.badge.find("a");
      this.documentBody = $(document.body);
      this.dropdown = $("#notification_dropdown");
      this.dropdownNotifications = this.dropdown.find(".notifications");
      this.ajaxLoader = this.dropdown.find(".ajax_loader");

      this.badgeLink.toggle(function(evt) {
          evt.preventDefault();
          evt.stopPropagation();
          self.ajaxLoader.show();
          self.badgeLink.removeClass( "red_tab" ).addClass("gray_tab");
          self.dropdown.css("display", "block");
          self.getNotifications(function() {
            self.renderNotifications();
          });
        },  function(evt) {
          evt.preventDefault();
          evt.stopPropagation();
          self.badgeLink.removeClass( "gray_tab" ).addClass("red_tab");
          self.dropdown.css("display", "none");
      });

      this.dropdown.click(function(evt) {
        evt.stopPropagation();
      });

      this.documentBody.click(function(evt) {
        if(self.dropdownShowing()) {
          self.badgeLink.click();
        }
      });
    };


    this.dropdownShowing = function() {
      return this.dropdown.css("display") === "block";
    };

    this.show_detail = function(){
      var element_id = $(this).attr( "id" );
      var detail = $( ".notification_detail_element[id='"+element_id+"']");
      $( "#notification_element" ).hide();
      $( "#return_back_note" ).show();
      detail.show();
      detail.addClass( "open" );
      $( ".see_all" ).hide();
      $( ".next_note" ).show();
    }

    this.getNotifications = function(callback) {
      $.get("/notifications/notifications_detail");
      $.getJSON("/notifications", function(notifications) {
        self.notifications = notifications;
        callback.apply(self, []);
      });
    };

    this.renderNotifications = function() {
      self.dropdownNotifications.empty();
      $.each(self.notifications.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          var note_avatr = $( "<div/>" ).addClass( "note_avatar" )
            .append($("<img/>", { src: notification.url,"class":"avatar" }));
          if (notification.size != "1"){
            note_avatr.append("<div class='avatar_shadow'><div class ='avatar_shadow'></div></div>")
          }

          var notificationElement = $("<div id='"+notification.id+"'/>")
            .click(self.show_detail )
            .addClass("notification_element")
            .html(notification.translation)
            .append(note_avatr)
            .append($("<abbr/>", {
              "class": "timeago",
              "title": notification.created_at
            }))
            .appendTo(self.dropdownNotifications);
          notificationElement.addClass("unread");
        
        });
      });
      message_count = $("#notification_badge .message_count span span");
      count = parseInt(message_count.html()) || 0;  
      count = count - 20;
      if( count > 0 ){
        message_count.text( count );
      }else{
        message_count.remove();
      }
      self.ajaxLoader.hide();
    };
  };

    Isport.widgets.add("notificationDropdown", NotificationDropdown); 
})();

  

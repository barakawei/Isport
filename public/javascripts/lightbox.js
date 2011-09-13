
jQuery.fn.center = (function() {
  var $window = $(window);
  return function () {
    this.css({
      position: "absolute",
      top: ($window.height() - this.height()) / 2 + $window.scrollTop() + "px",
      left:($window.width() - this.width()) / 2 + $window.scrollLeft() + "px"
    });
    return this;
  };
})();

(function() {
  var Lightbox = function() {
    var self = this;

    this.start = function() {
        this.pic = $( ".content_area" );
        this.lightbox= $("#lightbox");
        this.imageset= $("#lightbox-imageset");
        this.backdrop= $("#lightbox-backdrop");
        this.comment= $( "#lightbox-comment" );
        this.comment_panel= $( "#lightbox-comment-panel" );
        this.lightbox_leftside = $( "#lightbox-leftside" );
        this.lightbox_rightside = $( "#lightbox-rightside" );
        this.closelink= $("#lightbox-close-link");
        this.image= $("#lightbox-image");
        this.image_desc = $("#image-desc");
        this.left_sidebar = $(".left_sidebar");
        this.right_sidebar = $(".right_sidebar");
        this.body= $(document.body);
        this.window= $(window);
      
      self.pic.delegate("a.stream-photo-link", "click", self.lightboxImageClicked);
      self.imageset.delegate("img", "click", self.imagesetImageClicked);

      self.window.resize(function() {
        height =  (self.window.height()) + "px";
        width = (self.window.width()) + "px";
        left_width =  (self.window.width()-260)+ "px";
        self.lightbox.css("max-height",height);
        self.lightbox.css("max-width", width);
        self.lightbox_rightside.find( ".sidebar" ).css("height", height);
        self.comment.find( ".pic_comment_container" ).css("height", height);
        self.set_width( left_width );
      }).trigger("resize");

      self.closelink.click(function(evt){
        evt.preventDefault();
        self.resetLightbox();
      });

      self.left_sidebar.click(function(evt){
        self.left_sidebar.hide();
        self.right_sidebar.removeClass( "hide" );
        self.comment_panel.hide();
        left_width =  (self.window.width())+ "px";
        self.lightbox_rightside.css( "width","10px" );
        self.set_width( left_width );
      });
      self.right_sidebar.click(function(evt){
        self.right_sidebar.addClass( "hide" );
        self.left_sidebar.show();
        self.comment_panel.show();
        left_width =  (self.window.width()-260)+ "px";
        self.lightbox_rightside.css( "width","280px" );
        self.set_width( left_width );
      });

      self.lightbox_leftside.click(self.resetLightbox);

      self.body.keydown(function(evt) {
        var imageThumb = self.imageset.find("img.selected");

        switch(evt.keyCode) {
        case 27:
          self.resetLightbox();
          break;
        case 37:
          //left
          self.selectImage(self.prevImage(imageThumb));
          break;
        case 39:
          //right
          self.selectImage(self.nextImage(imageThumb));
          break;
        }
      });
    };

    this.nextImage = function(thumb){
      var next = thumb.next();
      if (next.length == 0) {
        next = self.imageset.find("img").first();
      }
      return(next);
    };

    this.prevImage = function(thumb){
      var prev = thumb.prev();
      if (prev.length == 0) {
        prev = self.imageset.find("img").last();
      }
      return(prev);
    };

    this.set_width = function( width ){
      self.lightbox_leftside.find( "#lightbox-content" ).css("width", width);
      self.lightbox_leftside.find( "#lightbox-imageset" ).css("width", width);
      self.lightbox_leftside.find( "#image-desc" ).css("width", width);
    }

    this.loadComments = function(pic_id){
      $.ajax({
        url:"/pic_comments",
        data: "pic_id="+pic_id,
        success: function(data){
          self.comment.html(data);
          $("abbr.timeago").timeago();
        }
      });
    };

    this.lightboxImageClicked = function(evt) {
      evt.preventDefault();
      var selectedImage = $(this).find("img.stream-photo"),
        imageUrl = selectedImage.attr("data-full-photo"),
        images = selectedImage.parents('.stream_element').find('img.stream-photo'),
        imageThumb;

      self.imageset.html("");
      images.each(function(index, image) {
        image = $(image);
        var thumb = $("<img/>", {
          src: image.attr("data-small-photo"),
          "data-full-photo": image.attr("data-full-photo"),
          "id": image.attr("id"),
          "desc": image.attr("desc")
        });
        
        if(image.attr("data-full-photo") == imageUrl) {
          imageThumb = thumb;
        };

        self.imageset.append(thumb);
      });

      self.selectImage(imageThumb).revealLightbox();

    };

    this.imagesetImageClicked = function(evt) { 
      evt.preventDefault();
      evt.stopPropagation();

      self.selectImage($(this));
    };

    this.selectImage = function(imageThumb) {
      var pic_id =  imageThumb.attr( "id" );
      self.loadComments(pic_id);
      $(".selected", self.imageset).removeClass("selected");
      imageThumb.addClass("selected");
      self.image.attr("src", imageThumb.attr("data-full-photo"));
      self.image_desc.html( imageThumb.attr( "desc" ) );
      return self;
    };

    this.revealLightbox = function() {
      self.body.addClass("lightboxed");
      self.lightbox
        .css("max-height", (self.window.height() - 100) + "px")
        .show();

      return self;
    };

    this.resetLightbox = function() {
      self.lightbox.hide();
      self.body.removeClass("lightboxed");
    };
  };
  Isport.widgets.add("Lightbox", Lightbox); 
})();


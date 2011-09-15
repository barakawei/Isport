
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
        this.lightbox_content = $( "#lightbox-content" );
        this.lightbox_rightside = $( "#lightbox-rightside" );
        this.closelink= $("#lightbox-close-link");
        this.image= $("#lightbox-image");
        this.image_desc = $("#image-desc");
        this.left_sidebar = $(".left_sidebar");
        this.right_sidebar = $(".right_sidebar");
        this.pic_left_arrow = $("#pic-left-arrow");
        this.pic_right_arrow = $("#pic-right-arrow");
        this.body= $(document.body);
        this.window= $(window);
        this.is_full = false;
        this.reday = false;
        this.image_width;
        this.image_height;
      
      self.pic.delegate("a.stream-photo-link", "click", self.lightboxImageClicked);
      self.imageset.delegate("img", "click", self.imagesetImageClicked);

      self.window.resize(function() {
        self.auto_resize_window(); 
        if( self.reday ){
          self.auto_resize_pic();
        }
      }).trigger("resize");

      self.pic_left_arrow.click(function(  ){
        var imageThumb = self.imageset.find("img.selected");
        self.selectImage(self.prevImage(imageThumb));
      });

      self.pic_right_arrow.click(function(  ){
        var imageThumb = self.imageset.find("img.selected");
        self.selectImage(self.nextImage(imageThumb));
      });

      
      self.closelink.click(function(evt){
        evt.preventDefault();
        self.resetLightbox();
      });

      self.left_sidebar.click(function(evt){
        self.left_sidebar.hide();
        self.right_sidebar.removeClass( "hide" );
        self.comment_panel.hide();
        left_width =  (self.window.width()-10);
        self.lightbox_rightside.css( "width","10px" );
        self.set_width( left_width );
        self.is_full = true;
      });
      self.right_sidebar.click(function(evt){
        self.right_sidebar.addClass( "hide" );
        self.left_sidebar.show();
        self.comment_panel.show();
        left_width =  (self.window.width()-280);
        self.lightbox_rightside.css( "width","280px" );
        self.set_width( left_width );
        self.is_full = false;
      });


      self.image.click(function(){
        var imageThumb = self.imageset.find("img.selected");
        self.selectImage(self.nextImage(imageThumb));
      });

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

    this.auto_resize_window = function(){
        var height =  (self.window.height()) + "px";
        var comment_height =  (self.window.height()-30) + "px";
        var width = (self.window.width()) + "px";
        var left_width;
        self.lightbox_rightside.find( ".sidebar" ).css("height", height);
        self.comment.find( ".pic_comment_container" ).css("height", comment_height);
        if(self.is_full ){
          left_width =  (self.window.width() -10);
        }else{
          left_width =  (self.window.width()-280);
        }
        self.set_width( left_width );
      };

    this.auto_resize_pic = function(){
      var content_width = self.lightbox_content.width();
      var content_height = self.lightbox_content.height()-200;
      self.image.aeImageResize({ height: content_height, width: content_width });
      //var margin_width = (content_width-origin_width)/2 ;
      //var new_width = content_width-80;
      //if(self.image_width <= new_width ){
        //new_width = self.image_width;
      //}
      //self.image.css( "width",new_width+"px");


      //if (window_height-85 <= content_height){
        //margin_height = content_height -85-window_height;
        //self.image.css( "width",new_width-margin_height+"px");
      //}
    }


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
      var left_width = Number(self.lightbox_content.css( "width" ).split("px")[0]);
      self.lightbox_content.css("width", width+"px");
      var left = Number(self.imageset.css("left").split("px")[0]);
      if( left == 0 ){
        self.imageset.css("left", (width/2)-35+"px");
      }else{ 
        var margin = (width-left_width)/2;
        self.imageset.css("left", left+margin+"px");
      }
      self.lightbox_leftside.find( "#image-desc" ).css("width", width+"px");
    }

    this.loadComments = function(pic_id){
      $.ajax({
        url:"/pic_comments",
        data: "pic_id="+pic_id,
        success: function(data){
          self.comment.html(data);
          self.image_width = self.image.width();
          self.image_height = self.image.height();
          $("abbr.timeago").timeago();
          self.auto_resize_window(); 
          self.reday = true;
        }
      });
    };

    this.lightboxImageClicked = function(evt) {
      evt.preventDefault();
      var selectedImage = $(this).find("img.stream-photo"),
        imageUrl = selectedImage.attr("data-full-photo"),
        images = selectedImage.closest( ".pic_container" ).find('img.stream-photo'),
        imageThumb;
      self.imageset.html("");
      images.each(function(index, image) {
        image = $(image);
        var thumb = $("<img/>", {
          src: image.attr("data-full-photo"),
          "data-full-photo": image.attr("data-full-photo"),
          "id": image.attr("id"),
          "desc": image.attr("desc"),
          "index":index
        });
        
        if(image.attr("data-full-photo") == imageUrl) {
          imageThumb = thumb;
        };

        self.imageset.append(thumb);
      });

      imageset_width =  self.imageset.find( "img" ).length * 70 +1000+"px";
      self.imageset.css( "width",imageset_width);
      self.selectImage(imageThumb).revealLightbox();
      self.auto_resize_pic();
      self.auto_image_height();

    };

    this.imagesetImageClicked = function(evt) { 
      evt.preventDefault();
      evt.stopPropagation();
      self.selectImage($(this));
    };

    this.selectImage = function(imageThumb) {
      self.reday = false;
      var pic_id =  imageThumb.attr( "id" );
      self.loadComments(pic_id);
      $(".selected", self.imageset).removeClass("selected");
      imageThumb.addClass("selected");
      self.image.css( "width","auto" );
      self.image.attr("src", imageThumb.attr("data-full-photo"));
      self.image_desc.html( imageThumb.attr( "desc" ) );
      var width = Number(self.lightbox_content.css( "width" ).split("px")[0]);
      var left = (width/2-35)-(imageThumb.attr("index") * 70);
      self.imageset.css("left", left+"px");
      self.auto_resize_pic();
      self.auto_image_height();
      return self;
    };

    this.auto_image_height = function(){
      self.image.one( "load", function() {
      var window_height = self.window.height();
      var margin_height_img = (window_height - 100 - self.image.height())/2;
      var margin_height_arrow = (window_height - 175 - self.pic_left_arrow.height())/2;
      self.image.css( "margin-top",margin_height_img+"px" );
      self.pic_left_arrow.css( "top",margin_height_arrow+"px" );
      self.pic_right_arrow.css( "top",margin_height_arrow+"px" );
      });
    }

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


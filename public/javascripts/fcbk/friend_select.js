function friend_select(get_url){   
     var url = arguments[0] ? arguments[0] : "/people/friend_select";
     $("#friend_select").empty();
     $("#friend_select").append(
     '<div class="filter" style="position:relative"> <input id="filter" type="text" style="width:100px;height:16px"></div><ul id="fcbklist"></ul><br><h4 id="error_message" style="float:left; display:none; color:red">您还没有选择好友!</h4><div class="glass_button " style="width: 40px;float:right" id="friend_select_button"><a href="#">完成</a></div>');
     
     var $fcbklist = $('#fcbklist');
     $('#friend_select_button').click( function(){
       var selectedIds = [  ];
        $fcbklist.find('li[addedid]').each(function(){
          selectedIds.push( this.id );
        }); 
        if (selectedIds.length == 0) {
          $('#error_message').fadeIn(1000, function() {
            $('#error_message').fadeOut(1000);
          }); 
          return false;
        }
        var selectedIdsStr = selectedIds.join( "," );
        friend_selected_callback( selectedIdsStr);
      });
    $.ajax({       
          type: "get",
          url:  url,
          success: function(result){
            $.each(result.data, function(i){
              $fcbklist.append(
              $('<li id="'+result.data[ i ].person.id+'">'+
              '<img class="avatar" title="'+result.data[ i ].person.name+'" alt="'+result.data[ i ].person.name+'" src="'+result.data[ i ].person.image_url+'"/>'+
              '<div class="content" style="position: absolute;left: 60px;top: 0">'+
              result.data[ i ].person.name+
              '</div></li>'
              ))
             });
            $.fcbkListSelection("#fcbklist","450","50","4");
            filter_friend( $fcbklist  );
            
          }

    
    });  
    }


    function filter_friend( $fcbklist  ){
    //id(ul id),width,height(element height),row(elements in row)        
        var $listItems = $fcbklist.find('li');
    // id (ul id), width, height (element height), row (elements in row) 
    $('#filter').keyup(function (){
      var $this = $(this);
      
      var val = $this.val();

      /*** Show all the listItems when the filter is cleared ***/
      if (!val) {
        $this.data('lastVal', val);
        $listItems.show();
        return;
      }

      var lastVal = $this.data('lastVal');
      $this.data('lastVal', val);
      /*** If the filter hasn't changed, do nothing ***/
      if(val === lastVal) { return; }
      
      /*** Hide the results of the previous filter ***/
      $listItems.filter(':visible').hide();

      /***
        Show only the items of the current tab that match
        the filter.
      ***/
      var $tabItems;
      switch($(".view_on").attr("id").replace("view_","")) {
        case "all":
          $tabItems = $listItems;
          break;
        case "selected":
          $tabItems = $listItems.filter('[addedid]');
          break;
        case "unselected":
          $tabItems = $listItems.filter(':not([addedid])');
          break;  
      }
      $tabItems.filter(':icontains(' + val + ')').show();
    });
    
    /***
      This is a custom pseudo-selector that selects
      elements whose text contains the specified substring.
      It is case-insensitive, unlike the built-in :contains selector.
    ***/
    $.extend($.expr[':'], {
      icontains: function(elem, i, match){
        return (new RegExp(match[3], 'im')).test($(elem).text());
      }
    });

 }


  $(function(){
    var loading = false;
    $(window).scroll(function(){
      if(loading){
        return;
      }
      if(reachBottom()){
        next_obj = $( ".next_page" ).last();
        $( ".previous_page" ).removeClass( "previous_page" );
        $( ".pagination" ).addClass( "scroll" );
        $( ".pagination" ).removeClass( "pagination" );
        next_obj.removeClass( "next_page" );
        next_page =next_obj.attr( "href" );
        if( next_page != null ){
          loading = true;
          next_obj.html('<img class="loading" src="/images/ui/loading.gif" alt="Loading">');
          $.getScript(next_page,function(){  next_obj.html('');loading = false; });  
          return false;
        }
      }
    });
  });



function reachBottom() {

    var scrollTop = 0;

    var clientHeight = 0;

    var scrollHeight = 0;

    if (document.documentElement && document.documentElement.scrollTop) {

        scrollTop = document.documentElement.scrollTop;

    } else if (document.body) {

        scrollTop = document.body.scrollTop;

    }

    if (document.body.clientHeight && document.documentElement.clientHeight) {

        clientHeight = (document.body.clientHeight < document.documentElement.clientHeight) ? document.body.clientHeight: document.documentElement.clientHeight;

    } else {

        clientHeight = (document.body.clientHeight > document.documentElement.clientHeight) ? document.body.clientHeight: document.documentElement.clientHeight;

    }

    scrollHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);

    if (scrollTop + clientHeight + 50 >= scrollHeight) {
        return true;
    } else {
        return false;
    }
}

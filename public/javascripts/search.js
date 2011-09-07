var Search = {
  selector : '#global_search_form input[type="text"]',
  formatItem: function(row){
    if(row['search']) {
      var data = { name: this.element.val() }
      return '搜索 '+data.name;
    } else {
      return "<img src='"+ row['image_url'] +"' class='avatar'/>" + row['name'];
    }
  },
  formatResult: function(row){
     return row['name'];
   },
  parse : function(data) {
    var results=new Array();
    for( var i in data ){
      person_element = data[ i ].person;
      person_json = {data : person_element, value : person_element['name']};
      results.push( person_json );
    }
    results.push(Search.searchLinkli.apply(this));
    return results;
  },
  selectItemCallback :  function(element, data, formatted) {
    if (data['search'] === true) { // The placeholder "search for" result
      window.location = this.element.parents("form").attr("action") + '?' + this.element.attr("name") +'=' + data['name'];
    } else { // The actual result
      element.val(formatted);
      window.location = data['url'];
    }
  },
  options : function(element){return {
      element: element,
      minChars : 1,
      onSelect: Search.selectItemCallback,
      max : 6,
      scroll : false,
      delay : 100,
      cacheLength : 15,
      extraParams : {limit : 5},
      formatItem : Search.formatItem,
      formatResult : Search.formatResult,
      parse : Search.parse
  };},

  searchLinkli : function() {
    var searchTerm = this.element.val();
    if(searchTerm[0] === "#"){
      searchTerm = searchTerm.slice(1);
    }
    return {
      data : {
        'search' : true,
        'url' : this.element.parents("form").attr("action") + '?' + this.element.attr("name") +'=' + searchTerm,
        'name' : searchTerm
      },
      value : searchTerm
    };
  },

  initialize : function() {
    $(Search.selector).each(function(index, element){
      var $element = $(element);
      var action = $element.parents("form").attr("action") + '.json';
      $element.autocomplete(action, Search.options($element));
    });
  }
}

$(document).ready(function(){
  Search.initialize();
});

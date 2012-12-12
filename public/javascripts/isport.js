(function() {
  if(typeof window.Isport !== "undefined") {
    return;
  }

  var Isport = { };

  Isport.WidgetCollection = function() {
    this.initialized = false;
    this.collection = { };
    this.eventsContainer = $({});
  };

  Isport.WidgetCollection.prototype.add = function(widgetId, Widget) {
    $.extend(Widget.prototype, Isport.BaseWidget);

    this[widgetId] = this.collection[widgetId] = new Widget();
    if(this.initialized) {
      this.collection[widgetId].start();
    }
  };

  Isport.WidgetCollection.prototype.remove = function(widgetId) {
    delete this.collection[widgetId];
  };

  Isport.WidgetCollection.prototype.init = function() {
    this.initialized = true;

    for(var widgetId in this.collection) {
      if(typeof this.collection[widgetId].start !== "undefined") {
        this.collection[widgetId].start();
      }
    };
  
  };

  Isport.WidgetCollection.prototype.subscribe = function(id, callback, context) {
    var ids = id.split(" ");
    for(var id in ids) {
      this.eventsContainer.bind(ids[id], $.proxy(callback, context));
    }
  };

  Isport.WidgetCollection.prototype.publish = function(id, args) {
    this.eventsContainer.trigger(id, args);
  };

  Isport.BaseWidget = {
    require: function(widgetName) {
      this[widgetName] = Isport.widgets[widgetName];
    }
  };

  Isport.widgets = new Isport.WidgetCollection();

  window.Isport = Isport;
})();


$(document).ready(function() { Isport.widgets.init(); });


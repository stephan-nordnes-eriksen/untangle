var EventAggregator;

EventAggregator = (function() {
  var responders, subscribers;

  function EventAggregator() {}

  subscribers = {};

  responders = {};

  EventAggregator.subscribe = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (subscribers[type]) {
      return subscribers[type].push(callback);
    } else {
      return subscribers[type] = [callback];
    }
  };

  EventAggregator.unSubscribe = function(type, callback) {
    var index;
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (subscribers[type]) {
      index = subscribers[type].indexOf(callback);
      if (index > -1) {
        return subscribers[type].splice(index, 1);
      }
    }
  };

  EventAggregator.respond = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    return responders[type] = callback;
  };

  EventAggregator.unRespond = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (responders[type] && responders[type] === callback) {
      return responders[type] = void 0;
    }
  };

  EventAggregator.publish = function(type, data) {
    var i, len, ref, results, subscriber;
    if (subscribers[type]) {
      ref = subscribers[type];
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        subscriber = ref[i];
        results.push(setTimeout(subscriber(data), 0));
      }
      return results;
    }
  };

  EventAggregator.request = function(type, data) {
    if (responders[type]) {
      return responders[type](data);
    }
    return null;
  };

  EventAggregator.helpers = function() {
    String.prototype.subscribe = function(data) {
      return EventAggregator.subscribe(this, data);
    };
    String.prototype.unSubscribe = function(data) {
      return EventAggregator.unSubscribe(this, data);
    };
    String.prototype.respond = function(data) {
      return EventAggregator.respond(this, data);
    };
    String.prototype.unRespond = function(data) {
      return EventAggregator.unRespond(this, data);
    };
    String.prototype.publish = function(data) {
      return EventAggregator.publish(this, data);
    };
    return String.prototype.request = function(data) {
      return EventAggregator.request(this, data);
    };
  };

  return EventAggregator;

})();

module.exports = EventAggregator;

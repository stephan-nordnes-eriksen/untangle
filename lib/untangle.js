var Untangle;

Untangle = (function() {
  var _reroutes, _responders, _subscribers, _subscribersAll;

  function Untangle() {}

  _subscribers = {};

  _subscribersAll = {};

  _responders = {};

  _reroutes = {};

  Untangle.subscribe = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (_subscribers[type]) {
      return _subscribers[type].push(callback);
    } else {
      return _subscribers[type] = [callback];
    }
  };

  Untangle.unSubscribe = function(type, callback) {
    var index;
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (_subscribers[type]) {
      index = _subscribers[type].indexOf(callback);
      if (index > -1) {
        return _subscribers[type].splice(index, 1);
      }
    }
  };

  Untangle.respond = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    return _responders[type] = callback;
  };

  Untangle.unRespond = function(type, callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    if (_responders[type] && _responders[type] === callback) {
      return _responders[type] = void 0;
    }
  };

  Untangle.publish = function(type, data) {
    var callback, j, len, ref, ref1, results, subscriber, subscribesToAll, toType;
    if (_subscribers[type]) {
      ref = _subscribers[type];
      for (j = 0, len = ref.length; j < len; j++) {
        subscriber = ref[j];
        setTimeout(subscriber(data), 0);
      }
    }
    for (subscribesToAll in _subscribersAll) {
      callback = _subscribersAll[subscribesToAll];
      setTimeout(callback(type, data), 0);
    }
    if (_reroutes[type]) {
      ref1 = _reroutes[type];
      results = [];
      for (toType in ref1) {
        callback = ref1[toType];
        if (typeof callback === "function") {
          results.push(Untangle.publish(toType, callback(data)));
        } else {
          results.push(Untangle.publish(toType, data));
        }
      }
      return results;
    }
  };

  Untangle.request = function(type, data) {
    if (_responders[type]) {
      return _responders[type](data);
    }
    return null;
  };

  Untangle.helpers = function() {
    String.prototype.subscribe = function(data) {
      return Untangle.subscribe(this.toString(), data);
    };
    String.prototype.unSubscribe = function(data) {
      return Untangle.unSubscribe(this.toString(), data);
    };
    String.prototype.respond = function(data) {
      return Untangle.respond(this.toString(), data);
    };
    String.prototype.unRespond = function(data) {
      return Untangle.unRespond(this.toString(), data);
    };
    String.prototype.publish = function(data) {
      return Untangle.publish(this.toString(), data);
    };
    String.prototype.request = function(data) {
      return Untangle.request(this.toString(), data);
    };
    String.prototype.reroute = function(data, callback) {
      return Untangle.reroute(this.toString(), data, callback);
    };
    return String.prototype.unReroute = function(data) {
      return Untangle.unReroute(this.toString(), data);
    };
  };

  Untangle.subscribeAll = function(callback) {
    if (typeof callback !== "function") {
      throw new Error("Callback not a function");
    }
    return _subscribersAll[callback] = callback;
  };

  Untangle.unSubscribeAll = function(callback) {
    return delete _subscribersAll[callback];
  };

  Untangle.reroute = function(fromType, toType, callback) {
    if (callback == null) {
      callback = true;
    }
    if (!_reroutes[fromType]) {
      _reroutes[fromType] = {};
    }
    return _reroutes[fromType][toType] = callback;
  };

  Untangle.unReroute = function(fromType, toType) {
    if (_reroutes[fromType] && _reroutes[fromType][toType]) {
      return delete _reroutes[fromType][toType];
    }
  };

  Untangle.resetAll = function(data) {
    var i, results;
    if (data === "HARD") {
      for (i in _subscribers) {
        delete _subscribers[i];
      }
      for (i in _subscribersAll) {
        delete _subscribersAll[i];
      }
      for (i in _responders) {
        delete _responders[i];
      }
      results = [];
      for (i in _reroutes) {
        results.push(delete _reroutes[i]);
      }
      return results;
    }
  };

  return Untangle;

})();

module.exports = Untangle;

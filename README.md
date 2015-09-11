![Untangle](/Untangle.png?raw=true)

# Untangle

[![Dependency status](https://img.shields.io/david/stephan-nordnes-eriksen/untangle.svg?style=flat)](https://david-dm.org/stephan-nordnes-eriksen/untangle)
[![devDependency Status](https://img.shields.io/david/dev/stephan-nordnes-eriksen/untangle.svg?style=flat)](https://david-dm.org/stephan-nordnes-eriksen/untangle#info=devDependencies)
[![Build Status](https://img.shields.io/travis/stephan-nordnes-eriksen/untangle.svg?style=flat&branch=master)](https://travis-ci.org/stephan-nordnes-eriksen/untangle)

[![NPM](https://nodei.co/npm/untangle.svg?style=flat)](https://npmjs.org/package/untangle)

An event aggregator for using the Publish/Subscribe pattern, also known as Pub/Sub. This version also have a Respond/Request feature.

Used together these two features allow you to create truly decoupled code. 

## Installation

    npm install untangle

## Usage Example

### Abstract
Untangle is a EventAggregator, or Pub/Sub, library. Untangle is meant to be used in a specific way. It is a library meant to create highly uncoupled code, meaning that classes and object has **NO** knowledge of each other. The addition, modification, or deletion of a class cannot affect any other class. To achieve this you must use Untangle in a specific way. There are a couple of rules:

1. No classes can know about the existence of other classes.
2. A class must be completely self-contained.
3. All interchange of information must go through the Untangle system.
4. All interchanged data must be "primitives", aka. boolean, number, string, or a hash or array consiting of the former datatypes.

Untangle has a concept not normally used in the Pub/Sub pattern, namely Respond/Request. This is in a way the opposite of Pub/Sub. In Untangle you can register that you `respond` to a certain message type. Whenever code `request` this massage later, then the callback which `respond` to this will return data to the requestee.

How to do the basics:

### Subscribing

```javascript
Untangle = require("untangle")

callback = function(data){console.log(data)}
Untangle.subscribe("MessageType", callback)
Untangle.publish("MessageType", "data")
=> "data"
Untangle.unSubscribe("MessageType", callback)
Untangle.publish("MessageType", "data")
=> no output
```

### Responding

```javascript
Untangle = require("untangle")

callback = function(data){data + " returned"}
Untangle.respond("MessageType", callback)
result = Untangle.request("MessageType", "data")
console.log(result)
=> "data returned"

Untangle.unRespond("MessageType", callback)
result = Untangle.request("MessageType", "data")
console.log(result)
=> null //Note: It returns null, not undefined.
```


### Conveniency method

```javascript
Untangle.helpers(); //Will activate prototypes on the String class:

callback = function(data){console.log(data)}
"MessageType".subscribe(callback)
"MessageType".publish("data")
=> "data"
"MessageType".unSubscribe(callback)
"MessageType".publish("data")
=> no output

callback = function(data){data + " returned"}
"MessageType".respond(callback)
"MessageType".request("data")
=> "data returned"
"MessageType".unRespond(callback)
"MessageType".request("data")
=> null
```

### More methods

#### .subscribeAll + .unSubscribeAll 
```javascript
callback = function(messageType, data){console.log("Got message of type " + messageType + ", with data " + data)}
Untangle.subscribeAll(callback) //Will receive every published message created. Great for logging all activity in the system.
"whatever".publish("some data")
=> "Got message of type whatever, with data some data"

Untangle.unSubscribeAll(callback) 
"whatever".publish("some data")
=> no output
```

#### .reroute + .unReroute
```javascript
callback = function( data){console.log(data)}
Untangle.subscribe("test2", callback)
Untangle.subscribe("test3", callback)
Untangle.reroute("test", "test2")
Untangle.reroute("test", "test3", function(data){data + " modified"})

"test".publish("test", "data")

=> "data"
=> "data modified"

Untangle.unReroute("test", "test2")
Untangle.unReroute("test", "test3")
"test".publish("test", "data")

=> no output
```

#### .resetAll
```javascript
	Untangle.resetAll(data)
```
This will remove everything inside Untangle, all listeners, all responders everything.

For this method to work you must supply the value `"HARD"` as data.

## Using Untangle on a system scale

```javascript
Untangle = require("untangle")
Untangle.helpers()

//Simulate a class similar to how CoffeeScript does it
User = (function() {
  var name;
  function User(name) {
    this.name = name;
    "logData".subscribe(this.loggerMethod);
    "getUserName".respond(this.getName.bind(this));
    "tick".subscribe(this.eatIfFish)
  }
  User.prototype.loggerMethod = function(data) {
    return console.log(data);
  };
  User.prototype.getName = function() {
    return this.name;
  };
  User.prototype.eatIfFish = function(tick) {
    if("isThereFish".request()){
      "I ate some fish".publish("and it was good")
    }
  };

  return User;
})();

Fish = (function() {
  function Fish() {
    "isThereFish".respond(this.isFish)
    "I ate some fish".subscribe(this.eatFish)
  }
  Fish.prototype.isFish = function() {
    return "getTick".request() > 10;
  };
  Fish.prototype.eatFish = function(data) {
    console.log("Omg! so horrible! And you even said " + data);
  };

  return Fish;
})();

Ticker = (function() {
  var timer;
  var tick;
  Ticker.prototype.getTick = function() {
    return this.tick;
  };
  function Ticker() {
    var self = this;
    "getTick".respond(this.getTick.bind(this));
    this.timer = setInterval(function() {
      if(!self.tick){self.tick = 0}
      self.tick += 1;
      "tick".publish(self.tick);
    }, 500);
  }
  
  return Ticker;
})();

var aUser = new User("The Users Name");
var fish = new Fish();
var ticker = new Ticker();

//...

var username = "getUserName".request()

```


## License

The MIT License (MIT)

Copyright 2015 Stephan Nordnes Eriksen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


### Thanks to
 - Cray-Cray Design for logo.

class Untangle
	_subscribers = {}
	_subscribersAll = {}
	_responders = {}
	_reroutes = {}

	@subscribe: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		
		if _subscribers[type]
			_subscribers[type].push( callback )
		else
			_subscribers[type] = [callback]

	@unSubscribe: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		if _subscribers[type]
			index = _subscribers[type].indexOf callback
			_subscribers[type].splice(index, 1) if index > -1

	@respond: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		
		_responders[type] = callback
			

	@unRespond: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		if _responders[type] && _responders[type] == callback
			_responders[type] = undefined

	@publish: (type, data) ->
		if _subscribers[type]
			for subscriber in _subscribers[type]
				setTimeout(subscriber(data), 0)

		for subscribesToAll, callback of _subscribersAll
			setTimeout(callback(type, data), 0)

		if _reroutes[type]
			for toType, callback of _reroutes[type]
				if typeof callback == "function"
					Untangle.publish(toType, callback(data))
				else
					Untangle.publish(toType, data)

	@request: (type, data) ->
		return _responders[type](data) if _responders[type]
		return null

	@helpers: ->
		String.prototype.subscribe = (data) ->
			Untangle.subscribe(this.toString(), data)
		String.prototype.unSubscribe = (data) ->
			Untangle.unSubscribe(this.toString(), data)
		String.prototype.respond = (data) ->
			Untangle.respond(this.toString(), data)
		String.prototype.unRespond = (data) ->
			Untangle.unRespond(this.toString(), data)
		String.prototype.publish = (data) ->
			Untangle.publish(this.toString(), data)
		String.prototype.request = (data) ->
			Untangle.request(this.toString(), data)
		String.prototype.reroute = (data, callback) ->
			Untangle.reroute(this.toString(), data, callback)
		String.prototype.unReroute = (data) ->
			Untangle.unReroute(this.toString(), data)

	@subscribeAll: (callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		_subscribersAll[callback] = callback

	@unSubscribeAll: (callback) ->
		delete _subscribersAll[callback]

	@reroute: (fromType, toType, callback=true) ->
		unless _reroutes[fromType]
			_reroutes[fromType] = {}
		
		_reroutes[fromType][toType] = callback

	@unReroute: (fromType, toType) ->
		if _reroutes[fromType] && _reroutes[fromType][toType]
			delete _reroutes[fromType][toType]

	@resetAll: (data) ->
		if data == "HARD"
			for i of _subscribers
				delete _subscribers[i]
			for i of _subscribersAll
				delete _subscribersAll[i]
			for i of _responders
				delete _responders[i]
			for i of _reroutes
				delete _reroutes[i]

module.exports = Untangle
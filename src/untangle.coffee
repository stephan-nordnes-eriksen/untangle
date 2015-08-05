
class Untangle
	subscribers = {}
	subscribersAll = {}
	responders = {}
	reroutes = {}

	@subscribe: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		
		if subscribers[type]
			subscribers[type].push( callback )
		else
			subscribers[type] = [callback]

	@unSubscribe: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		if subscribers[type]
			index = subscribers[type].indexOf callback
			subscribers[type].splice(index, 1) if index > -1

	@respond: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		
		responders[type] = callback
			

	@unRespond: (type, callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		if responders[type] && responders[type] == callback
			responders[type] = undefined

	@publish: (type, data) ->
		if subscribers[type]
			for subscriber in subscribers[type]
				setTimeout(subscriber(data), 0)

		for subscribesToAll, callback of subscribersAll
			setTimeout(callback(type, data), 0)

		if reroutes[type]
			for toType, callback of reroutes[type]
				if typeof callback == "function"
					Untangle.publish(toType, callback(data))
				else
					Untangle.publish(toType, data)

	@request: (type, data) ->
		return responders[type](data) if responders[type]
		return null

	@helpers: ->
		String.prototype.subscribe = (data) ->
			Untangle.subscribe(this, data)
		String.prototype.unSubscribe = (data) ->
			Untangle.unSubscribe(this, data)
		String.prototype.respond = (data) ->
			Untangle.respond(this, data)
		String.prototype.unRespond = (data) ->
			Untangle.unRespond(this, data)	
		String.prototype.publish = (data) ->
			Untangle.publish(this, data)
		String.prototype.request = (data) ->
			Untangle.request(this, data)

	@subscribeAll: (callback) ->
		unless typeof callback == "function"
			throw new Error "Callback not a function"
		subscribersAll[callback] = callback

	@unSubscribeAll: (callback) ->
		delete subscribersAll[callback]

	@reroute: (fromType, toType, callback=true) ->
		unless reroutes[fromType]
			reroutes[fromType] = {}
		
		reroutes[fromType][toType] = callback

	@unReroute: (fromType, toType) ->
		delete reroutes[fromType][toType] if reroutes[fromType] && reroutes[fromType][toType]

module.exports = Untangle

class Untangle
	subscribers = {}
	responders = {}

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

module.exports = Untangle
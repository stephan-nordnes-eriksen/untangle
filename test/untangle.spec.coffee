chai = require("chai")
sinon = require("sinon")
sinonChai = require("sinon-chai")
chai.should()
chai.use(sinonChai)
expect = chai.expect
assert = chai.assert
# using compiled JavaScript file here to be sure module works
Untangle = require '../lib/untangle.js'

describe 'untangle', ->
	beforeEach ->
		Untangle.resetAll "HARD"

	it 'exposes .subscribe, .unSubscribe, .publish, .respond and .unRespond', ->
		expect(typeof Untangle.subscribe  ).to.equal("function")
		expect(typeof Untangle.unSubscribe).to.equal("function")
		expect(typeof Untangle.respond    ).to.equal("function")
		expect(typeof Untangle.unRespond  ).to.equal("function")
		expect(typeof Untangle.publish    ).to.equal("function")

	describe 'common properties', ->
		it 'accepts a string and a callback function', ->
			expect(Untangle.subscribe.bind(Untangle  , "Test", (->) )).to.not.throw(Error);
			expect(Untangle.unSubscribe.bind(Untangle, "Test", (->) )).to.not.throw(Error);
			expect(Untangle.respond.bind(Untangle    , "Test", (->) )).to.not.throw(Error);
			expect(Untangle.unRespond.bind(Untangle  , "Test", (->) )).to.not.throw(Error);
		it 'throws error if callback isn\'t function', ->
			expect(Untangle.subscribe  .bind(Untangle, "Test", 1 )).to.throw(Error);
			expect(Untangle.unSubscribe.bind(Untangle, "Test", 1 )).to.throw(Error);
			expect(Untangle.respond    .bind(Untangle, "Test", 1 )).to.throw(Error);
			expect(Untangle.unRespond  .bind(Untangle, "Test", 1 )).to.throw(Error);

	describe ".subscribe", ->
		it "receives published message of type", ->
			spy = sinon.spy()

			Untangle.subscribe("messageType", spy)
			Untangle.publish("messageType", "data")

			expect(spy).to.have.been.calledWith("data")

	describe ".unSubscribe", ->
		it "does not receive published message of type", ->
			spy = sinon.spy()

			Untangle.subscribe("messageType", spy)
			Untangle.unSubscribe("messageType", spy)
			Untangle.publish("messageType", "data")

			spy.should.have.not.been.called

	describe ".respond", ->
		it "callback is called", ->
			spy = sinon.spy()

			Untangle.respond("messageType", spy)
			Untangle.request("messageType", "data")

			expect(spy).to.have.been.calledWith("data")

		it "returns data from callback", ->
			spy = (-> "data2")

			Untangle.respond("messageType", spy)
			returned = Untangle.request("messageType", "data")

			assert(returned, "data2")

		it "only one is allowed per message type", ->
			spy = sinon.spy()
			spy2 = sinon.spy()
			
			Untangle.respond("messageType", spy)
			Untangle.respond("messageType", spy2)
			Untangle.request("messageType", "data")

			spy.should.have.not.been.called
			expect(spy2).to.have.been.calledWith("data")

	describe ".unRespond", ->
		it "does not receive request message of type", ->
			spy = sinon.spy()

			Untangle.respond("messageType", spy)
			Untangle.unRespond("messageType", spy)
			Untangle.request("messageType", "data")

			spy.should.have.not.been.called

	describe ".publish", ->
		it "sends message to all subscribers", ->
			spy = sinon.spy()
			spy2 = sinon.spy()

			Untangle.subscribe("messageType", spy)
			Untangle.subscribe("messageType", spy2)
			Untangle.publish("messageType", "data")

			expect(spy).to.have.been.calledWith("data")
			expect(spy2).to.have.been.calledWith("data")
		it "does not crash if there are no subscribers", ->
			expect(Untangle.publish.bind(Untangle, "messageType", "data")).to.not.throw(Error)

	describe ".request", ->
		it "request data from responder", ->
			returnFunction = (data) -> 1
			Untangle.respond("messageType", returnFunction)
			assert(Untangle.request("messageType", "data"), 1)

		it "does not crash if there are no responders", ->
			expect(Untangle.request.bind(Untangle, "messageType", "data")).to.not.throw(Error)
		
		it "returns null if there are no responders", ->
			expect(Untangle.request("messageType", "data")).to.equal(null)
			


	describe ".helpers", ->
		before ->
			Untangle.helpers()

		it "adds methods to string", ->
			expect("string").to.respondTo("publish")
			expect("string").to.respondTo("request")
			expect("string").to.respondTo("subscribe")
			expect("string").to.respondTo("unSubscribe")
			expect("string").to.respondTo("respond")
			expect("string").to.respondTo("unRespond")

	describe ".subscribeAll", ->
		it "receives all types of published messages", ->
			spy = sinon.spy()
			Untangle.subscribeAll(spy)
			Untangle.publish("messageType", "data")
			expect(spy).to.have.been.calledWith("messageType", "data")
		it "receives multiple callbacks", ->
			spy = sinon.spy()
			Untangle.subscribeAll(spy)
			Untangle.publish("messageType", "data")
			Untangle.publish("messageType2", "data2")
			expect(spy).to.have.been.calledWith("messageType", "data")
			expect(spy).to.have.been.calledWith("messageType2", "data2")
	
	describe ".unSubscribeAll", ->
		it "receives no published messages", ->
			spy = sinon.spy()
			Untangle.subscribeAll(spy)
			Untangle.unSubscribeAll(spy)
			Untangle.publish("messageType", "data")
			spy.should.have.not.been.called

	describe ".reroute", ->
		it "reroutes messages of type1 to type2", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.reroute("messageType2", "messageType")
			Untangle.publish("messageType2", "data")
			expect(spy).to.have.been.calledWith("data")

		it "reroutes and transforms data of type1 to type2", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.reroute("messageType2", "messageType", ((data)-> data+" transformed"))
			Untangle.publish("messageType2", "data")

			expect(spy).to.have.been.calledWith("data transformed")

	describe ".unReroute", ->
		it "does not reroutes messages of type1 to type2", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.reroute("messageType2", "messageType")
			Untangle.unReroute("messageType2", "messageType")
			Untangle.publish("messageType2", "data")
			spy.should.have.not.been.called
		it "does not reroutes and transforms data of type1 to type2", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.reroute("messageType2", "messageType", ((data)-> data+" transformed"))
			Untangle.unReroute("messageType2", "messageType")
			Untangle.publish("messageType2", "data")
			spy.should.have.not.been.called

	describe ".resetAll", ->
		it "does nothing if not HARD is sent to it.", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.resetAll("HARD Wrong")
			Untangle.publish("messageType", "data")
			expect(spy).to.have.been.calledWith("data")

		it "subscribers no longer get their messages", ->
			spy = sinon.spy()
			Untangle.subscribe("messageType", spy)
			Untangle.resetAll("HARD")
			Untangle.publish("messageType", "data")
			spy.should.have.not.been.called
chai = require("chai")
sinon = require("sinon")
sinonChai = require("sinon-chai")
chai.should()
chai.use(sinonChai)
expect = chai.expect
assert = chai.assert
# using compiled JavaScript file here to be sure module works
EventAggregator = require '../lib/event-aggregator.js'

describe 'event-aggregator', ->
	it 'exposes .subscribe, .unSubscribe, .publish, .respond and .unRespond', ->
		expect(typeof EventAggregator.subscribe  ).to.equal("function")
		expect(typeof EventAggregator.unSubscribe).to.equal("function")
		expect(typeof EventAggregator.respond    ).to.equal("function")
		expect(typeof EventAggregator.unRespond  ).to.equal("function")
		expect(typeof EventAggregator.publish    ).to.equal("function")

	describe 'common properties', ->
		it 'accepts a string and a callback function', ->
			expect(EventAggregator.subscribe.bind(EventAggregator  , "Test", (->) )).to.not.throw(Error);
			expect(EventAggregator.unSubscribe.bind(EventAggregator, "Test", (->) )).to.not.throw(Error);
			expect(EventAggregator.respond.bind(EventAggregator    , "Test", (->) )).to.not.throw(Error);
			expect(EventAggregator.unRespond.bind(EventAggregator  , "Test", (->) )).to.not.throw(Error);
		it 'throws error if callback isn\'t function', ->
			expect(EventAggregator.subscribe  .bind(EventAggregator, "Test", 1 )).to.throw(Error);
			expect(EventAggregator.unSubscribe.bind(EventAggregator, "Test", 1 )).to.throw(Error);
			expect(EventAggregator.respond    .bind(EventAggregator, "Test", 1 )).to.throw(Error);
			expect(EventAggregator.unRespond  .bind(EventAggregator, "Test", 1 )).to.throw(Error);

	describe ".subscribe", ->
		it "receives published message of type", ->
			spy = sinon.spy()

			EventAggregator.subscribe("messageType", spy)
			EventAggregator.publish("messageType", "data")

			expect(spy).to.have.been.calledWith("data")

	describe ".unSubscribe", ->
		it "does not receive published message of type", ->
			spy = sinon.spy()

			EventAggregator.subscribe("messageType", spy)
			EventAggregator.unSubscribe("messageType", spy)
			EventAggregator.publish("messageType", "data")

			spy.should.have.not.been.called

	describe ".respond", ->
		it "callback is called", ->
			spy = sinon.spy()

			EventAggregator.respond("messageType", spy)
			EventAggregator.request("messageType", "data")

			expect(spy).to.have.been.calledWith("data")

		it "returns data from callback", ->
			spy = (-> "data2")

			EventAggregator.respond("messageType", spy)
			returned = EventAggregator.request("messageType", "data")

			assert(returned, "data2")

		it "only one is allowed per message type", ->
			spy = sinon.spy()
			spy2 = sinon.spy()
			
			EventAggregator.respond("messageType", spy)
			EventAggregator.respond("messageType", spy2)
			EventAggregator.request("messageType", "data")

			spy.should.have.not.been.called
			expect(spy2).to.have.been.calledWith("data")

	describe ".unRespond", ->
		it "does not receive request message of type", ->
			spy = sinon.spy()

			EventAggregator.respond("messageType", spy)
			EventAggregator.unRespond("messageType", spy)
			EventAggregator.request("messageType", "data")

			spy.should.have.not.been.called

	describe ".publish", ->
		it "sends message to all subscribers", ->
			spy = sinon.spy()
			spy2 = sinon.spy()

			EventAggregator.subscribe("messageType", spy)
			EventAggregator.subscribe("messageType", spy2)
			EventAggregator.publish("messageType", "data")

			expect(spy).to.have.been.calledWith("data")
			expect(spy2).to.have.been.calledWith("data")
		it "does not crash if there are no subscribers", ->
			expect(EventAggregator.publish.bind(EventAggregator, "messageType", "data")).to.not.throw(Error)

	describe ".request", ->
		it "request data from responder", ->

		it "does not crash if there are no responders", ->
			expect(EventAggregator.request.bind(EventAggregator, "messageType", "data")).to.not.throw(Error)
		
		it "returns null if there are no responders", ->
			expect(EventAggregator.request("messageType", "data")).to.equal(null)
			


	describe "helpers", ->
		before ->
			EventAggregator.helpers()

		it "adds methods to string", ->
			expect("string").to.respondTo("publish")
			expect("string").to.respondTo("request")
			expect("string").to.respondTo("subscribe")
			expect("string").to.respondTo("unSubscribe")
			expect("string").to.respondTo("respond")
			expect("string").to.respondTo("unRespond")

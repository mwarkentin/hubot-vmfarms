chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'vmfarms', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/vmfarms')(@robot)

  it 'registers a respond listener for the server api', ->
    expect(@robot.respond).to.have.been.calledWith(/vmf(arms)? server me\s?([\w-]+)?/i)

  it 'registers a respond listener for the pricing page', ->
    expect(@robot.respond).to.have.been.calledWith(/vmf(arms)? price me/i)

  it 'registers a respond listener for the monitoring api', ->
    expect(@robot.respond).to.have.been.calledWith(/vmf(arms)? pause monitoring (\d+)/i)

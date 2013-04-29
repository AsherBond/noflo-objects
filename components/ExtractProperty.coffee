noflo = require("noflo")
_ = require("underscore")
_s = require("underscore.string")

class ExtractProperty extends noflo.Component

  description: _s.clean "Given a key, return only the value matching that key
  in the incoming object"

  constructor: ->
    @key = null

    @inPorts =
      in: new noflo.Port
      key: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.key.on "data", (@key) =>

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup(group)

    @inPorts.in.on "data", (data) =>
      if @key? and _.isObject(data)
        @outPorts.out.send data[@key]

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new ExtractProperty

noflo = require "noflo"
_ = require "underscore"
_s = require "underscore.string"
{ deepCopy } = require "owl-deepcopy"

class FilterProperty extends noflo.Component

  description: _s.clean "Filter out some properties by matching RegExps
  against the keys of incoming objects"

  constructor: ->
    @keys = []
    @recurse = false
    @keep = false

    @inPorts =
      in: new noflo.Port
      key: new noflo.Port
      recurse: new noflo.Port
      keep: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.keep.on "data", (keep) =>
      @keep = true if keep is "true"

    @inPorts.recurse.on "data", (data) =>
      @recurse = true if data is "true"

    @inPorts.key.on "connect", =>
      @keys = []
    @inPorts.key.on "data", (key) =>
      @keys.push new RegExp key, "g"

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup group

    @inPorts.in.on "data", (data) =>
      if _.isObject data
        data = deepCopy data
        @filter data
        @outPorts.out.send data

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

  filter: (object) ->
    return if _.isEmpty object

    for key, value of object
      isMatched = false

      for filter in @keys
        match = key.match filter
        if not @keep and match or
           @keep and not match
          delete object[key]
          isMatched = true
          break

      if not isMatched and _.isObject(value) and @recurse
        @filter value

exports.getComponent = -> new FilterProperty

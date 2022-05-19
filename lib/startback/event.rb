module Startback
  #
  # An Event occuring a given context and having a type and attached data.
  #
  # Event instances have String types that are by default unrelated to ruby
  # classes. Also, this Event class has a `json` information contract that
  # allows dumping & reloading them easily. A context or context_factory may
  # be provided in dress world to reload the event context from data, but
  # that logic is opaque to this class.
  #
  # This class is intended to be subclassed if a more specific event protocol
  # is wanted.
  #
  class Event

    def initialize(type, data, context = nil)
      @type = type.to_s
      @data = OpenStruct.new(data)
      @context = context
    end
    attr_reader :context, :type, :data

    def self.json(src, context)
      parsed = JSON.parse(src)
      klass = Kernel.const_get(parsed['type'])
      klass.new(parsed['type'], parsed['data'], context)
    end

    def to_json(*args, &bl)
      h = {
        type: self.type,
        data: data.to_h
      }
      h[:context] = context if context
      h.to_json(*args, &bl)
    end

  end # class Event
end # module Startback
require_relative 'event/ext/context'
require_relative 'event/ext/operation'
require_relative 'event/agent'
require_relative 'event/bus'
require_relative 'event/engine'

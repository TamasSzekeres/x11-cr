require "./c/Xlib"
require "./event"

module X11
  # Wrapper for `X11::C::X::ErrorEvent` structure.
  class ErrorEvent < Event
    def initialize
      @event = X11::C::X::ErrorEvent.new
    end

    def initialize(event : X11::C::X::PErrorEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::ErrorEvent)
    end

    def to_unsafe : X11::C::X::PErrorEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::ErrorEvent
      @event
    end

    def type : Int32
      @event.type
    end

    def type=(type : Int32)
      @event.type = type
    end

    def serial : UInt64
      @event.serial
    end

    def serial=(serial : UInt64)
      @event.serial = serial
    end

    def error_code : UInt8
      @event.error_code
    end

    def error_code=(error_code : UInt8)
      @event.error_code = error_code
    end

    def request_code : UInt8
      @event.request_code
    end

    def request_code=(request_code : UInt8)
      @event.request_code = request_code
    end

    def minor_code : UInt8
      @event.minor_code
    end

    def minor_code=(minor_code : UInt8)
      @event.minor_code = minor_code
    end

    def resource_id : X11::C::XID
      @event.resource_id
    end

    def resource_id=(resource_id : X11::C::XID)
      @event.resource_id = resource_id
    end
  end
end

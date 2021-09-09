require "./c/Xlib"
require "./event"

module X11
  # Wrapper for `X11::C::X::GenericEvent` structure.
  class GenericEvent < Event
    def initialize
      @event = X11::C::X::GenericEventCookie.new
    end

    def initialize(event : X11::C::X::PGenericEventCookie)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::GenericEventCookie)
    end

    def to_unsafe : X11::C::X::PGenericEventCookie
      pointerof(@event)
    end

    def to_x : X11::C::X::GenericEventCookie
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

    def send_event : Bool
      @event.send_event ? true : false
    end

    def send_event=(send_event : Bool)
      @event.send_event = send_event ? 1 : 0
    end

    def display : Display
      Display.new @event.display
    end

    def display=(display : Display)
      @event.display = display.to_unsafe
    end

    def extension : Int32
      @event.extension
    end

    def extension=(extension : Int32)
      @event.extension = extension
    end

    def ev_type : Int32
      @event.ev_type
    end

    def ev_type=(ev_type : Int32)
      @event.ev_type = ev_type
    end

    def cookie : UInt32
      @event.cookie
    end

    def cookie=(cookie : UInt32)
      @event.cookie = cookie
    end

    def data : Void*
      @event.data
    end

    def data=(data : Void*)
      @event.data = data
    end
  end

  alias GenericEventCookie = GenericEvent
end

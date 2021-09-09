require "./c/Xlib"
require "./event"

module X11
  # Wrapper from `X11::C::X::NoExposeEvent` structure.
  class NoExposeEvent < Event
    def initialize
      @event = X11::C::X::NoExposeEvent.new
    end

    def initialize(event : X11::C::X::PNoExposeEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::NoExposeEvent)
    end

    def to_unsafe : X11::C::X::PNoExposeEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::NoExposeEvent
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

    def drawable : X11::C::Drawable
      @event.drawable
    end

    def drawable=(drawable : X11::C::Drawable)
      @event.drawable = drawable
    end

    def major_code : Int32
      @event.major_code
    end

    def major_code=(major_code : Int32)
      @event.major_code = major_code
    end

    def minor_code : Int32
      @event.minor_code
    end

    def minor_code=(minor_code : Int32)
      @event.minor_code = minor_code
    end
  end
end

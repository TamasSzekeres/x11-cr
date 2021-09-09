require "./c/Xlib"
require "./event"

module X11
  # Wrapper from `X11::C::X::SelectionRequestEvent` structure.
  class SelectionRequestEvent < Event
    def initialize
      @event = X11::C::X::SelectionRequestEvent.new
    end

    def initialize(event : X11::C::X::PSelectionRequestEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::SelectionRequestEvent)
    end

    def to_unsafe : X11::C::X::PSelectionRequestEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::SelectionRequestEvent
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

    def owner : X11::C::Window
      @event.owner
    end

    def owner=(owner : X11::C::Window)
      @event.owner = owner
    end

    def requestor : X11::C::Window
      @event.requestor
    end

    def requestor=(requestor : X11::C::Window)
      @event.requestor = requestor
    end

    def selection : X11::C::Atom
      @event.selection
    end

    def selection=(selection : X11::C::Atom)
      @event.selection = selection
    end

    def target : X11::C::Atom
      @event.target
    end

    def target=(target : X11::C::Atom)
      @event.target = target
    end

    def property : X11::C::Atom
      @event.property
    end

    def property=(property : X11::C::Atom)
      @event.property = property
    end

    def time : X11::C::Time
      @event.time
    end

    def time=(time : X11::C::Time)
      @event.time = time
    end
  end
end

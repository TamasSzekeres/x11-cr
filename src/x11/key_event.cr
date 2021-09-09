require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper from `X11::C::X::KeyEvent` structure.
  class KeyEvent < WindowEvent
    def initialize
      @event = X11::C::X::KeyEvent.new
    end

    def initialize(key_event : X11::C::X::PKeyEvent)
      raise BadAllocException.new if key_event.null?
      @event = key_event.value
    end

    def initialize(@event : X11::C::X::KeyEvent)
    end

    # Returns the KeySym from the list that corresponds to the `keycode` member
    #
    # ###Arguments
    # - **index** Specifies the index into the KeySyms list for the event's KeyCode.
    #
    # ###Description
    # The `lookup_keysym` function uses a given keyboard event and the index you
    # specified to return the KeySym from the list that corresponds to the KeyCode
    # member in the `KeyPressedEvent` or `KeyReleasedEvent` structure.
    # If no KeySym is defined for the KeyCode of the event, `lookup_leysym` returns `NoSymbol`.
    #
    # ###See also
    # `lookup_string`, `Display::rebind_keysym`, `MappingEvent::refresh_keyboard_mapping`,
    # `ButtonEvent`, `MapEvent`.
    def lookup_keysym(index : Int32) : X11::C::KeySym
      X.lookup_keysym to_unsafe, index
    end

    # Translates key event to a string and a keysym.
    def lookup_string : NamedTuple(string: String, keysym: KeySym)
      buffer = StaticArray(UInt8, 10).new(0)
      X.lookup_string(to_unsafe, buffer.to_unsafe, 10, out keysym, nil)
      {string: String.new(buffer.to_unsafe), keysym: keysym}
    end

    def to_unsafe : X11::C::X::PKeyEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::KeyEvent
      @event
    end

    def press? : Bool
      @event.type == KeyPress
    end

    def release? : Bool
      @event.type == KeyRelease
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

    def window : X11::C::Window
      @event.window
    end

    def window=(window : X11::C::Window)
      @event.window = window
    end

    def root : X11::C::Window
      @event.root
    end

    def root=(root : X11::C::Window)
      @event.root = root
    end

    def sub_window : X11::C::Window
      @event.subwindow
    end

    def sub_window=(sub_window : X11::C::Window)
      @event.subwindow = sub_window
    end

    def time : X11::C::Time
      @event.time
    end

    def time=(time : X11::C::Time)
      @event.time = time
    end

    def x : Int32
      @event.x
    end

    def x=(x : Int32)
      @event.x = x
    end

    def y : Int32
      @event.y
    end

    def y=(y : Int32)
      @event.y = y
    end

    def x_root : Int32
      @event.x_root
    end

    def x_root=(x_root : Int32)
      @event.x_root = x_root
    end

    def y_root : Int32
      @event.y_root
    end

    def y_root=(y_root : Int32)
      @event.y_root = y_root
    end

    def state : UInt32
      @event.state
    end

    def state=(state : UInt32)
      @event.state = state
    end

    def keycode : UInt32
      @event.keycode
    end

    def keycode=(keycode : UInt32)
      @event.keycode = keycode
    end

    def same_screen : Bool
      @event.same_screen ? true : false
    end

    def same_screen=(same_screen : Bool)
      @event.same_screen = same_screen ? 1 : 0
    end
  end
end

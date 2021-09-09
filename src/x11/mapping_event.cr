require "./c/Xlib"
require "./window_event"

module X11
  # Wrapper for `X11::C::X::MappingEvent` structure.
  class MappingEvent < WindowEvent
    def initialize
      @event = X11::C::X::MappingEvent.new
    end

    def initialize(event : X11::C::X::PMappingEvent)
      raise BadAllocException.new if event.null?
      @event = event.value
    end

    def initialize(@event : X11::C::X::MappingEvent)
    end

    def to_unsafe : X11::C::X::PMappingEvent
      pointerof(@event)
    end

    def to_x : X11::C::X::MappingEvent
      @event
    end

    # Refreshes the stored modifier and keymap information.
    #
    # ###Description
    # The `refresh_keyboard_mapping` function refreshes the stored modifier and
    # keymap information. You usually call this function when a **MappingNotify**
    # event with a request member of **MappingKeyboard** or **MappingModifier**
    # occurs. The result is to update Xlib's knowledge of the keyboard.
    #
    # ###See also
    # `KeyEvent::lookup_keysym`, `KeyEvent::lookup_string`, `Display::rebind_keysym`,
    # `X11::string_to_keysym`, `ButtonEvent`, `MapEvent`.
    def refresh_keyboard_mapping : Int32
      X.refresh_keyboard_mapping @event
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

    def request : Int32
      @event.request
    end

    def request=(request : Int32)
      @event.request = request
    end

    def first_keycode : Int32
      @event.first_keycode
    end

    def first_keycode=(first_keycode : Int32)
      @event.first_keycode = first_keycode
    end

    def count : Int32
      @event.count
    end

    def count=(count : Int32)
      @event.count = count
    end
  end
end

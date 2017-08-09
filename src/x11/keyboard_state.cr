require "./c/Xlib"

module X11
  struct KeyboardState
    def initialize
      @keyboard_state = X11::C::X::KeyboardState.new
    end

    def initialize(keyboard_state : X11::C::X::PKeyboardState)
      raise BadAllocException.new if keyboard_state.null?
      @keyboard_state = keyboard_state.value
    end

    def initialize(@keyboard_state : X11::C::X::KeyboardState)
    end

    def to_unsafe : X11::C::X::PKeyboardState
      pointerof(@keyboard_state)
    end

    def to_x : X11::C::X::KeyboardState
      @keyboard_state
    end

    def key_click_percent : Int32
      @keyboard_state.key_click_percent
    end

    def key_click_percent=(key_click_percent : Int32)
      @keyboard_state.key_click_percent = key_click_percent
    end

    def bell_percent : Int32
      @keyboard_state.bell_percent
    end

    def bell_percent=(bell_percent : Int32)
      @keyboard_state.bell_percent = bell_percent
    end

    def bell_pitch : UInt32
      @keyboard_state.bell_pitch
    end

    def bell_pitch=(bell_pitch : UInt32)
      @keyboard_state.bell_pitch = bell_pitch
    end

    def bell_duration : UInt32
      @keyboard_state.bell_duration
    end

    def bell_duration=(bell_duration : UInt32)
      @keyboard_state.bell_duration = bell_duration
    end

    def led_mask : UInt64
      @keyboard_state.led_mask
    end

    def led_mask=(led_mask : UInt64)
      @keyboard_state.led_mask = led_mask
    end

    def global_auto_repeat : Int32
      @keyboard_state.global_auto_repeat
    end

    def global_auto_repeat=(global_auto_repeat : Int32)
      @keyboard_state.global_auto_repeat = global_auto_repeat
    end

    def auto_repeats : StaticArray(UInt8, 32)
      @keyboard_state.auto_repeats
    end

    def auto_repeats=(auto_repeats : StaticArray(UInt8, 32))
      @keyboard_state.auto_repeats = auto_repeats
    end
  end
end

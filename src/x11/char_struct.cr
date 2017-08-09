require "./c/Xlib"

module X11
  # Wraper for `X11::C::X::CharStruct` structure.
  struct CharStruct
    def initialize
      @char_struct = X11::C::X::CharStruct.new
    end

    def initialize(char_struct : X11::C::X::PCharStruct)
      raise BadAllocException.new if char_struct.null?
      @char_struct = char_struct.value
    end

    def initialize(@char_struct : X11::C::X::CharStruct)
    end

    def to_unsafe : X11::C::X::PCharStruct
      pointerof(@char_struct)
    end

    def to_x : X11::C::X::CharStruct
      @char_struct
    end

    def bearing : Int16
      @char_struct.bearing
    end

    def bearing=(bearing : Int16)
      @char_struct.bearing = bearing
    end

    def rbearing : Int16
      @char_struct.rbearing
    end

    def rbearing=(rbearing : Int16)
      @char_struct.rbearing = rbearing
    end

    def width=(width : Int16)
      @char_struct.width = width
    end

    def ascent=(ascent : Int16)
      @char_struct.ascent = ascent
    end

    def descent=(descent : Int16)
      @char_struct.descent = descent
    end

    def attributes=(attributes : UInt16)
      @char_struct.attributes = attributes
    end
  end
end

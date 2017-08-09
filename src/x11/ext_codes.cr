require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::ExtCodes` structure.
  struct ExtCodes
    def initialize
      @ext_codes = X11::C::X::ExtCodes.new
      @ext_codes.extension = 1
      @ext_codes.major_opcode = 0
      @ext_codes.first_event = 0
      @ext_codes.first_error = 0
    end

    def initialize(ext_codes : X11::C::X::PExtCodes)
      raise BadAllocException.new if ext_codes.null?
      @ext_codes = ext_codes.value
    end

    def initialize(@ext_codes : X11::C::X::ExtCodes)
    end

    def to_unsafe : X11::C::X::PExtCodes
      pointerof(@ext_codes)
    end

    def to_x : X11::C::X::ExtCodes
      @ext_codes
    end

    def extension : Int32
      @ext_codes.extension
    end

    def extension=(extension : Int32)
      @ext_codes.extension = extension
    end

    def major_opcode : Int32
      @ext_codes.major_opcode
    end

    def major_opcode=(major_opcode : Int32)
      @ext_codes.major_opcode = major_opcode
    end

    def first_event : Int32
      @ext_codes.first_event
    end

    def first_event=(first_event : Int32)
      @ext_codes.first_event = first_event
    end

    def first_error : Int32
      @ext_codes.first_error
    end

    def first_error=(first_error : Int32)
      @ext_codes.first_error = first_error
    end
  end
end

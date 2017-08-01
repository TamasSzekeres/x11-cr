require "./c/Xlib"

module X11
  # Wrapper for `X11::C::X::ExtData` structure.
  struct ExtData
    def initialize
      @ext_data = X11::C::X::ExtData.new
    end

    def initialize(ext_data : X11::C::X::PExtData)
      raise BadAllocException.new if ext_data.null?
      @ext_data = ext_data.value
    end

    def initialize(@ext_data : X11::C::X::ExtData)
    end

    def to_unsafe : X11::C::X::PExtData
      pointerof(@ext_data)
    end

    def to_x : X11::C::X::ExtData
      @ext_data
    end

    def number : Int32
      @ext_data.number
    end

    def number=(number : Int32)
      @ext_data.number = number
    end

    def next : ExtData?
      if @ext_data.next.null?
        nil
      else
        ExtData.new @ext_data.next
      end
    end

    def next=(data : ExtData)
      @ext_data.next = data.to_unsafe
    end

    def free_private : X11::C::X::PExtData -> Int32
      @ext_data.free_private
    end

    def free_private=(free_private : X11::C::X::PExtData -> Int32)
      @ext_data.free_private = free_private
    end

    def private_data : X11::C::X::Pointer
      @ext_data.private_data
    end

    def private_data=(private_data : X11::C::X::Pointer)
      @ext_data.private_data = private_data
    end
  end
end

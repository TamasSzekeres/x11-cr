require "./c/Xlib"

module X11
  struct ServerInterpretedAddress
    def initialize(type : String, value : String)
      @server_interpreted_address = X11::C::X::ServerInterpretedAddress.new
      @server_interpreted_address.typelength = type.size
      @server_interpreted_address.type = type.to_unsafe
      @server_interpreted_address.valuelength = value.size
      @server_interpreted_address.value = value.to_unsafe
    end

    def initialize(server_interpreted_address : X11::C::X::PServerInterpretedAddress)
      raise BadAllocException.new if server_interpreted_address.null?
      @server_interpreted_address = server_interpreted_address.value
    end

    def initialize(@server_interpreted_address : X11::C::X::ServerInterpretedAddress)
    end

    def to_unsafe : X11::C::X::PServerInterpretedAddress
      pointerof(@server_interpreted_address)
    end

    def to_x : X11::C::X::ServerInterpretedAddress
      @server_interpreted_address
    end

    def family : Int32
      X11::C::FamilyServerInterpreted
    end

    def type_length : Int32
      @server_interpreted_address.typelength
    end

    def type : String
      String.new @server_interpreted_address.type
    end

    def value_length : Int32
      @server_interpreted_address.valuelength
    end

    def value : String
      String.new @server_interpreted_address.value
    end
  end
end

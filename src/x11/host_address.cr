require "./c/Xlib"

module X11
  struct HostAddress
    def initialize(family : Int32, data : Bytes | ServerInterpretedAddress)
      @host_address = X11::C::X::HostAddress.new
      @host_address.family = family
      case data
      when Bytes
        @host_address.length = data.size
        @host_address.address = data.to_unsafe.as(PChar)
      when ServerInterpretedAddress
        @host_address.size = sizeof(ServerInterpretedAddress)
        @host_address.address = data.to_unsafe.as(PChar)
      end
    end

    def initialize(host_address : X11::C::X::PHostAddress)
      raise BadAllocException.new if host_address.null?
      @host_address = host_address.value
    end

    def initialize(@host_address : X11::C::X::HostAddress)
    end

    def to_unsafe : X11::C::X::PHostAddress
      pointerof(@host_address)
    end

    def to_x : X11::C::X::HostAddress
      @host_address
    end

    def family : Int32
      @host_address.family
    end

    def length : Int32
      @host_address.length
    end

    def address : X11::C::PChar
      @host_address.address
    end

    def bytes : Bytes
      Bytes.new @host_address.address, @host_address.length
    end

    def internet? : Bool
      family == X11::C::FamilyInternet
    end

    def dec_net? : Bool
      family == X11::C::FamilyDECnet
    end

    def chaos? : Bool
      family == X11::C::FamilyChaos
    end

    def internet6? : Bool
      family == X11::C::FamilyInternet6
    end

    def server_interpreted?
      family == X11::C::FamilyServerInterpreted
    end

    def server_interpreted_address : ServerInterpretedAddress?
      if family == X11::C::FamilyServerInterpreted
        ServerInterpretedAddress.new @host_address.address.as(X11::C::X::PServerInterpretedAddress)
      else
        nil
      end
    end
  end
end

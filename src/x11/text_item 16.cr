require "./c/Xlib"

module X11
  struct TextItem16
    def initialize(@text_item : X11::C::X::TextItem16)
    end

    def initialize(text_item : X11::C::X::PTextItem16)
      raise BadAllocException.new if text_item.null?
      @text_item = text_item.value
    end

    def initialize
      @text_item = X11::C::X::TextItem16.new
    end

    def initialize(chars : Array(X11::C::X::Char2b), delta : Int32, font : X11::C::Font)
      @text_item = X11::C::X::TextItem16.new
      @text_item.chars = chars.to_unsafe
      @text_item.nchars = chars.size
      @text_item.delta = delta
      @text_item.font = font
    end

    def chars : Array(X11::C::X::Char2b)
      Array(X11::C::X::Char2b).new @text_item.chars
    end

    def chars=(chars : Array(X11::C::X::Char2b))
      @text_item.chars = chars.to_unsafe
      @text_item.nchars = chars.size
    end

    def nchars : Int32
      @text_item.nchars
    end

    def delta : Int32
      @text_item.delta
    end

    def delta=(delta : Int32)
      @text_item.delta = delta
    end

    def font : X11::C::Font
      @text_item.font
    end

    def font=(font : X11::C::Font)
      @text_item.font = font
    end

    def to_x : X11::C::X::TextItem16
      @text_item
    end

    def to_unsafe : X11::C::X::PTextItem16
      pointerof(@text_item)
    end
  end
end

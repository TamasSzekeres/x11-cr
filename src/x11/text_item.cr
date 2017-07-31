require "./c/Xlib"

module X11
  struct TextItem
    def initialize(@text_item : X11::C::X::TextItem)
    end

    def initialize(text_item : X11::C::X::PTextItem)
      raise BadAllocException.new if text_item.null?
      @text_item = text_item.value
    end

    def initialize
      @text_item = X11::C::X::TextItem.new
    end

    def initialize(chars : String, delta : Int32, font : X11::C::Font)
      @text_item = X11::C::X::TextItem.new
      @text_item.chars = chars.to_unsafe
      @text_item.nchars = chars.size
      @text_item.delta = delta
      @text_item.font = font
    end

    def chars : String
      String.new @text_item.chars
    end

    def chars=(chars : String)
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

    def to_x : X11::C::X::TextItem
      @text_item
    end

    def to_unsafe : X11::C::X::PTextItem
      pointerof(@text_item)
    end
  end
end

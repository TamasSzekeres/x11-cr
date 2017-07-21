require "./c/Xlib"

module X11
  class PixmapFormatValues
    property depth : Int32
    property bits_per_pixel : Int32
    property scanline_pad : Int32

    def initialize(pixmap_format_values : X11::C::X::PPixmapFormatValues)
      @depth = pixmap_format_values.value.depth
      @bits_per_pixel = pixmap_format_values.value.bits_per_pixel
      @scanline_pad = pixmap_format_values.value.scanline_pad
    end

    def initialize(pixmap_format_values : X11::C::X::PixmapFormatValues)
      @depth = pixmap_format_values.depth
      @bits_per_pixel = pixmap_format_values.bits_per_pixel
      @scanline_pad = pixmap_format_values.scanline_pad
    end

    def initialize(@depth : Int32, @bits_per_pixel : Int32, @scanline_pad : Int3)
    end

    def to_x : X11::C::X::PixmapFormatValues
      s = X11::C::X::PixmapFormatValues.new
      s.depth = @depth
      s.bits_per_pixel = @bits_per_pixel
      s.scanline_pad = @scanline_pad
      s
    end
  end
end

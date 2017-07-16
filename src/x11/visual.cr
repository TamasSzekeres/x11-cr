require "./c/Xlib"

module X11
  class Visual
    getter display : Display
    getter visual : X11::C::X::PVisual

    def initialize(@display : Display, @visual : X11::C::X::PVisual)
      raise BadAllocException.new if @visual.null?
    end

    # Allocates the memory needed for an XImage structure for the specified display but does not allocate space for the image itself.
    # Rather, it initializes the structure byte-order, bit-order, and bitmap-unit values from the display and returns a pointer to the XImage structure.
    # The red, green, and blue mask values are defined for Z format images only and are derived from the Visual structure passed in.
    # Other values also are passed in. The *offset* permits the rapid displaying of the image without requiring each scanline to be shifted into position.
    # If you pass a zero value in *bytes_per_line*, Xlib assumes that the scanlines are contiguous in memory and calculates the value of *bytes_per_line* itself.
    #
    # - **depth** Specifies the depth of the image.
    # - **format** Specifies the format for the image. You can pass XYBitmap, XYPixmap, or ZPixmap.
    # - **offset** Specifies the number of pixels to ignore at the beginning of the scanline.
    # - **data** Specifies the image data.
    # - **width** Specifies the width of the image, in pixels.
    # - **height** Specifies the height of the image, in pixels.
    # - **bitmap_pad** Specifies the quantum of a scanline (8, 16, or 32). In other words, the start of one scanline is separated in client memory from the start of the next scanline by an integer multiple of this many bits.
    # - **bytes_per_line** Specifies the number of bytes in the client image between the start of one scanline and the start of the next.
    def create_image(depth : UInt32, format : Int32, offset : Int32, data : Bytes, width : UInt32, height : UInt32, bitmap_pad : Int32, bytes_per_line : Int32) : Image
      Image.new(self, X.create_image(@display.dpy, @visual, depth, format, offset, data.to_unsafe, width, height, bitmap_pad, bytes_per_line))
    end
  end
end

require "./c/Xlib"

module X11
  class Image
    getter image : X11::C::X::PImage

    def initialize(@image : X11::C::X::PImage)
      raise BadAllocException.new if @image.null?
    end

    # Initializes the internal image manipulation routines of the underlieing image structure.,
    # based on the values of the various structure members.
    #
    # All fields other than the manipulation routines must already be initialized.
    # If the `bytes_per_line` member is zero,
    # `init` will assume the image data is contiguous in memory and set the `bytes_per_line` member
    # to an appropriate value based on the other members; otherwise,
    # the value of `bytes_per_line` is not changed.
    # All of the manipulation routines are initialized to functions that other Xlib image manipulation functions
    # need to operate on the the type of image specified by the rest of the structure.
    #
    # This function must be called for any image constructed by the client before passing it to any other function.
    # Image structures created or returned by Xlib do not need to be initialized in this fashion.
    #
    # This function returns a nonzero status if initialization of the structure is successful.
    # It returns zero if it detected some error or inconsistency in the structure, in which case the image is not changed.
    #
    # ###See also
    # `add_pixel`, `Display::create_image`, `finalize`, `pixel`, `Display::put_image`,
    # `put_pixel`, `Display::sub_image`.
    def init : Int32
      X.init_image @image
    end

    def finalize
      @image.value.f.destroy_image
    end

    def to_unsafe : X11::C::X::PImage
      @image
    end
  end
end

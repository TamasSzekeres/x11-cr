require "./c/Xlib"

module X11
  include C

  # This is part of libXtst.
  class RecordExtension
    # The underlying Display object. Docs recommend using two separate
    # connections for control and data.
    getter ctrl_display = Display.new
    # :ditto:
    getter data_display = Display.new

    # Connects to the display and raises if Record Extension Library was not found
    # on the system.
    def initialize
      @ctrl_display.synchronize(true)
      version = X.record_query_version(@ctrl_display.dpy, out _, out _)
      raise "X Record Extension Library not installed. You probably need to install libXtst on your system." if version == 0
    end

    # Returns a new context.
    # A *range* can be created with `create_range`.
    #
    # Example usage:
    # ```
    # range = record.create_range
    # range.device_events.first = ::X11::KeyPress
    # range.device_events.last = ::X11::ButtonRelease
    # context = record.create_context(record_range)
    # ```
    def create_context(range : X::RecordRange, *, flags = 0, client_spec = X::RecordClientSpec::AllClients)
      p_range = pointerof(range)
      X.record_create_context(@ctrl_display.dpy, 0, pointerof(client_spec), 1, pointerof(p_range), 1)
    end

    # Create a mutable `range` for usage in `create_context`.
    def create_range
      ::X11::X.record_alloc_range.value
    end

    @async_callback_box : Pointer(Void)?
    # Start listening for the events configured in `context.range`.
    # This method does not block. The block does not get run on its own,
    # you need to additionally repeatedly call `process_replies`.
    # For the structure of `record_data.data`, please refer to xEvent (NOT XEvent)
    # at `_xEvent` in `Xproto.h`. There are no docs available for this, only
    # other reference implementations.
    #
    # Example usage:
    # ```
    # record.enable_context_async(context) do |record_data|
    #   next if record_data.category != ::X11::X::RecordInterceptDataCategory::FromServer.value
    #   xevent = record_data.data
    #   repeat = xevent[2] == 1
    #   next if repeat
    #   type = xevent[0]
    #   keycode = xevent[1]
    #   state = xevent[28]
    #   pp! type, keycode, state
    # end
    # fd = IO::FileDescriptor.new record.data_display.connection_number
    # loop do
    #   dpy_fd.wait_readable
    #   record.process_replies
    # end
    # ```
    def enable_context_async(context : X::RecordContext, &callback : X::RecordInterceptData ->)
      boxed = Box.box(callback)
      @async_callback_box = boxed
      status = X.record_enable_context_async(@data_display.dpy, context, ->(closure_data, record_data) do
        closure_as_callback = Box(typeof(callback)).unbox(closure_data)
        closure_as_callback.call(record_data.value)
      end, boxed)
      raise "Could not enable record context" if status == 0
    end

    def process_replies
      X.record_process_replies(@data_display.dpy)
    end

    def finalize
      close
    end

    def close : Int32
      res1 = @ctrl_display.close
      res2 = @data_display.close
      res1 == 0 ? res2 : res1
    end
  end
end

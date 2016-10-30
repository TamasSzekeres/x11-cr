module X11
  @[Link("X11")]
  lib Xlib
    alias Pointer = UInt8*
    alias Status = Int32

    alias Bool = Int32

    $_Xdebug : Int32

    alias PExtData = ExtData*
    struct ExtData
      number : Int32 # number returned by XRegisterExtension
      next : PExtData # next item on list of data for structure
      free_private : PExtData -> Int32 # called to free private storage
      private_data : Pointer # data private to this extension
    end

    # This file contains structures used by the extension mechanism.
    alias PExtCodes = ExtCodes*
    struct ExtCodes # public to extension, cannot be changed
      extension : Int32 # extension number
      major_opcode : Int32 # major op-code assigned by server
      first_event : Int32 # first event number for the extension
      first_error : Int32 # first error number for the extension
    end

    # Data structure for retrieving info about pixmap formats.
    alias PPixmapFormatValues = PixmapFormatValues*
    struct PixmapFormatValues
      depth : Int32
      bits_per_pixel : Int32
      scanline_pad : Int32
    end

    # Data structure for setting graphics context.
    alias PGCValues = GCValues*
    struct GCValues
      function : Int32 # logical operation
      plane_mask : UInt64 # plane mask
      foreground : UInt64 # foreground pixel
      background : UInt64 # background pixel
      line_width : Int32 # line width
      line_style : Int32 # LineSolid, LineOnOffDash, LineDoubleDash
      cap_style : Int32 # CapNotLast, CapButt, CapRound, CapProjecting
    	join_style: Int32 # JoinMiter, JoinRound, JoinBevel
      fill_style : Int32 # FillSolid, FillTiled, FillStippled, FillOpaeueStippled
      fill_rule : Int32 # EvenOddRule, WindingRule
      arc_mode : Int32 # ArcChord, ArcPieSlice
      tile : Pixmap # tile pixmap for tiling operations
      stipple : Pixmap # stipple 1 plane pixmap for stipping
      ts_x_origin : Int32 # offset for tile or stipple operations
      ts_y_origin : Int32
      font : Font # default text font for text operations
      subwindow_mode : Int32 # ClipByChildren, IncludeInferiors
      graphics_exposures : Bool # boolean, should exposures be generated
      clip_x_origin : Int32 # origin for clipping
      clip_y_origin : Int32
      clip_mask : Pixmap # bitmap clipping; other calls for rects
      dash_offset : Int32 # patterned/dashed line information
      dashes : UInt8;
    end

    alias GC = Pointer

    # Visual structure; contains information about colormapping possible.
    alias PVisual = Visual*
    struct Visual
      ext_data : PExtData # hook for extension to hang data
      visualid : VisualID # visual id of this visual
    	c_class : Int32; # class of screen (monochrome, etc.)
    	red_mask, green_mask, blue_mask : UInt64 # mask values
      bits_per_rgb : Int32 # log base 2 of distinct color values
      map_entries : Int32 # color map entries
    end

    # Depth structure; contains information for each possible depth.
    alias PDepth = Depth*
    struct Depth
      depth : Int32 # this depth (Z) of the depth
      nvisuals : Int32 # number of Visual types at this depth
      visuals : PVisual # list of visuals possible at this depth
    end

    # Information about the screen.  The contents of this structure are
    # implementation dependent.  A Screen should be treated as opaque
    # by application code.

    alias PScreen = Screen*
    struct Screen
      ext_data : PExtData # hook for extension to hang data
      display : PDisplay # back pointer to display structure
      root : Window # Root window id.
      width, height : Int32 # width and height of screen
      mwidth, mheight : Int32 # width and height of  in millimeters
      ndepths : Int32 # number of depths possible
      depths : PDepth # list of allowable depths on the screen
      root_depth : Int32 # bits per pixel
      root_visual : PVisual # root visual
      default_gc : GC # GC for the root root visual
      cmap : Colormap # default color map
      white_pixel : UInt64
      black_pixel : UInt64 # White and Black pixel values
      max_maps, min_maps : Int32 # max and min color maps
      backing_store : Int32 # Never, WhenMapped, Always
      save_unders : Bool;
      oot_input_mask : Int64 # initial root input mask
    end

    # Format structure; describes ZFormat data the screen will understand.
    alias PScreenFormat = ScreenFormat*
    struct ScreenFormat
      ext_data : PExtData  # hook for extension to hang data
      depth : Int32 # depth of this image format
      bits_per_pixel : Int32 # bits/pixel at this depth
      scanline_pad : Int32 # scanline must padded to this multiple
    end

    # Data structure for setting window attributes.
    alias PSetWindowAttributes = SetWindowAttributes*
    struct SetWindowAttributes
      background_pixmap : Pixmap # background or None or ParentRelative
      background_pixel : UInt64 # background pixel
      border_pixmap : Pixmap # border of the window
      border_pixel : UInt64 # border pixel value
      bit_gravity : Int32 # one of bit gravity values
      win_gravity : Int32 # one of the window gravity values
      backing_store : Int32 # NotUseful, WhenMapped, Always
      backing_planes : UInt64 # planes to be preseved if possible
      backing_pixel : UInt64 # value to use in restoring planes
      save_under : Bool # should bits under be saved? (popups)
      event_mask : Int64 # set of events that should be saved
      do_not_propagate_mask : Int64 # set of events that should not propagate
      override_redirect : Bool # boolean value for override-redirect
      colormap : Colormap # color map to be associated with window
      cursor : Cursor # cursor to be displayed (or None)
    end

    alias PWindowAttributes = WindowAttributes*
    struct WindowAttributes
      x, y : Int32 # location of window
      width, height : Int32 # width and height of window
      border_width : Int32 # border width of window
      depth : Int32 # depth of window
      visual : PVisual # the associated visual structure
      root : Window # root of screen containing window
      c_class : Int32 # InputOutput, InputOnly
      bit_gravity : Int32 # one of bit gravity values
      win_gravity : Int32 # one of the window gravity values
      backing_store : Int32 # NotUseful, WhenMapped, Always
      backing_planes : UInt64 # planes to be preserved if possible
      backing_pixel : UInt64 # value to be used when restoring planes
      save_under : Bool # boolean, should bits under be saved?
      colormap : Colormap # color map to be associated with window
      map_installed : Bool # boolean, is color map currently installed
      map_state : Int32 # IsUnmapped, IsUnviewable, IsViewable
      all_event_masks : Int64 # set of events all people have interest in
      your_event_mask : Int64 # my event mask
      do_not_propagate_mask : Int64 # set of events that should not propagate
      override_redirect : Bool # boolean value for override-redirect
      screen : PScreen # back pointer to correct screen
    end

    # Data structure for host setting; getting routines.

    alias PHostAddress = HostAddress*
    struct HostAddress
      family : Int32 # for example FamilyInternet
      length : Int32 # length of address, in bytes
      address : PChar # pointer to where to find the bytes
    end

    # Data structure for ServerFamilyInterpreted addresses in host routines
    alias PServerInterpretedAddress = ServerInterpretedAddress*
    struct ServerInterpretedAddress
      typelength : Int32 # length of type string, in bytes
      valuelength : Int32 # length of value string, in bytes
      type : PChar # pointer to where to find the type string
      value : PChar # pointer to where to find the address
    end

    struct Image_Funcs
      create_image : PDisplay, PVisual, UInt32, Int32, Int32, PChar, UInt32, UInt32, Int32, Int32 -> PImage
      destroy_image : PImage -> Int32
      get_pixel : PImage, Int32, Int32 -> UInt64
      set_pixel : PImage, Int32, Int32, UInt64 -> Int32
      sub_image : PImage, Int32, Int32, UInt32, UInt32 -> PImage
      add_pixel : PImage, UInt64 -> Int32
    end

    # Data structure for "image" data, used by image manipulation routines.
    alias PImage = Image*
    struct Image
      width, height : Int32 # size of image
      xoffset : Int32 # number of pixels offset in X direction
      format : Int32 # XYBitmap, XYPixmap, ZPixmap
      data : PChar # pointer to image data
      byte_order : Int32 # data byte order, LSBFirst, MSBFirst
      bitmap_unit : Int32 # quant. of scanline 8, 16, 32
      bitmap_bit_order : Int32 # LSBFirst, MSBFirst
      bitmap_pad : Int32 # 8, 16, 32 either XY or ZPixmap
      depth : Int32 # depth of image
      bytes_per_line : Int32 # accelarator to next line
      bits_per_pixel : Int32 # bits per pixel (ZPixmap)
      red_mask : UInt64 # bits in z arrangment
      green_mask : UInt64
      blue_mask : UInt64
      obdata : Pointer # hook for the object routines to hang on
      f : Image_Funcs # image manipulation routines
    end

    # Data structure for XReconfigureWindow
    alias PWindowChanges = WindowChanges*
    struct WindowChanges
      x, y : Int32
      width, height : Int32
      border_width : Int32;
      sibling : Window;
      stack_mode : Int32;
    end

    # Data structure used by color operations
    alias PColor = Color*
    struct Color
      pixel : UInt64
      red, green, blue : UInt16
      flags : UInt8 # do_red, do_green, do_blue
      pad : UInt8
    end

    # Data structures for graphics operations.  On most machines, these are
    # congruent with the wire protocol structures, so reformatting the data
    # can be avoided on these architectures.
    alias PSegment = Segment*
    struct Segment
      x1, y1, x2, y2 : Int16
    end

    alias PPoint = Point*
    struct Point
      x, y : Int16
    end

    alias PRectangle = Rectangle*
    struct Rectangle
      x, y : Int16
      width, height : UInt16
    end

    alias PArc = Arc*
    struct Arc
      x, y : Int16
      width, height : UInt16
      angle1, angle2 : Int16
    end


    # Data structure for XChangeKeyboardControl

    alias PKeyboardControl = KeyboardControl*
    struct KeyboardControl
      key_click_percent : Int32
      bell_percent : Int32
      bell_pitch : Int32
      bell_duration : Int32
      led : Int32
      led_mode : Int32
      key : Int32
      auto_repeat_mode : Int32 # On, Off, Default
    end

    # Data structure for XGetKeyboardControl

    alias PKeyboardState = KeyboardState*
    struct KeyboardState
      key_click_percent : Int32
      bell_percent : Int32
      bell_pitch, bell_duration : UInt32
      led_mask : UInt64
      global_auto_repeat : Int32
      auto_repeats : UInt8[32]
    end

    # Data structure for XGetMotionEvents.

    alias PTimeCoord = TimeCoord*
    struct TimeCoord
      time : Time
      x, y : Int16
    end

    # Data structure for X{Set,Get}ModifierMapping

    alias PModifierKeymap = ModifierKeymap
    struct ModifierKeymap
      max_keypermod : Int32 # The server's max # of keys per modifier
      modifiermap : PKeyCode # An 8 by max_keypermod array of modifiers
    end

    alias PPrivate = Pointer
    alias PXrmHashBucketRec = Pointer

    alias PDisplay = Display*
    struct Display
      ext_data : PExtData # hook for extension to hang data
      private1 : PPrivate
      fd : Int32 # Network socket.
      private2 : Int32
      proto_major_version : Int32 # major version of server's X protocol
      proto_minor_version : Int32 # minor version of servers X protocol
      vendor : PChar # vendor of the server hardware
      private3 : XID
      private4 : XID
      private5 : XID
      private6 : Int32
      resource_alloc : PDisplay -> XID # allocator function
      byte_order : Int32 # screen byte order, LSBFirst, MSBFirst
      bitmap_unit : Int32 # padding and data requirements
      bitmap_pad : Int32 # padding requirements on bitmaps
      bitmap_bit_order : Int32 # LeastSignificant or MostSignificant
      nformats : Int32 # number of pixmap formats in list
      pixmap_format : PScreenFormat # pixmap format list
      private8 : Int32
      release : Int32 # release of the server
      private9, private10 : PPrivate
      qlen : Int32 # Length of input event queue
      last_request_read : UInt64 # seq number of last event read
      request : UInt64 # sequence number of last request.
      private11 : Pointer
      private12 : Pointer
      private13 : Pointer
      private14 : Pointer
      max_request_size : UInt32 # maximum number 32 bit words in request
      db : PXrmHashBucketRec
      private15 : PDisplay -> Int32
      display_name : PChar # "host:display" string used on this connect
      default_screen : Int32 # default screen for operations
      nscreens : Int32 # number of screens on this server
      screens : PScreen # pointer to list of screens
      motion_buffer : UInt64 # size of motion buffer
      private16 : UInt64
      min_keycode : Int32 # minimum defined keycode
      max_keycode : Int32 # maximum defined keycode
      private17 : Pointer
      private18 : Pointer
      private19 : Int32
      xdefaults : PChar # contents of defaults from server
      # there is more to this structure, but it is private to Xlib
    end

    # Definitions of specific events.

    alias PKeyEvent = KeyEvent*
    struct KeyEvent
      type : Int32 # of event
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window it is reported relative to
      root : Window # root window that the event occurred on
      subwindow : Window # child window
      time : Time # milliseconds
      x, y : Int32 # pointer x, y coordinates in event window
      x_root, y_root : Int32 # coordinates relative to root
      state : UInt32 # key or button mask
      keycode : UInt32 # detail
      same_screen : Bool # same screen flag
    end

    alias PKeyPressedEvent = KeyPressedEvent*
    alias KeyPressedEvent = KeyEvent

    alias PKeyReleasedEvent = KeyReleasedEvent*
    alias KeyReleasedEvent = KeyEvent

    alias PButtonEvent = ButtonEvent*
    struct ButtonEvent
      type : Int32 # of event
      serial : UInt32 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window it is reported relative to
      root : Window # root window that the event occurred on
      subwindow : Window # child window
      time : Time # milliseconds
      x, y : Int32 # pointer x, y coordinates in event window
      x_root, y_root : Int32 # coordinates relative to root
      state : UInt32 # key or button mask
      button : UInt32 # detail
      same_screen : Bool # same screen flag
    end

    alias PButtonPressedEvent = ButtonPressedEvent*
    alias ButtonPressedEvent = ButtonEvent

    alias PButtonReleasedEvent = ButtonReleasedEvent*
    alias ButtonReleasedEvent = ButtonEvent

    alias PMotionEvent = MotionEvent*
    struct MotionEvent
      type : Int32 # of event
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window reported relative to
      root : Window # root window that the event occurred on
      subwindow : Window # child window
      time : Time # milliseconds
      x, y : Int32 # pointer x, y coordinates in event window
      x_root, y_root : Int32 # coordinates relative to root
      state : UInt32 # key or button mask
      is_hint : UInt8 # detail
      same_screen : Bool # same screen flag
    end

    alias PPointerMovedEvent = PointerMovedEvent*
    alias PointerMovedEvent = MotionEvent

    alias PCrossingEvent = CrossingEvent*
    struct CrossingEvent
      type : Int32 # of event
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window reported relative to
      root : Window # root window that the event occurred on
      subwindow : Window # child window
      time : Time # milliseconds
      x, y : Int32 # pointer x, y coordinates in event window
      x_root, y_root : Int32 # coordinates relative to root
      mode : Int32 # NotifyNormal, NotifyGrab, NotifyUngrab
      detail : Int32
      # NotifyAncestor, NotifyVirtual, NotifyInferior,
      # NotifyNonlinear,NotifyNonlinearVirtual
      same_screen : Bool # same screen flag
      focus : Bool # boolean focus
      state : UInt32 # key or button mask
    end

    alias PEnterWindowEvent = EnterWindowEvent*
    alias EnterWindowEvent = CrossingEvent

    alias PLeaveWindowEvent = LeaveWindowEvent*
    alias LeaveWindowEvent = CrossingEvent

    alias PFocusChangeEvent = FocusChangeEvent*
    struct FocusChangeEvent
      type : Int32 # FocusIn or FocusOut
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window reported relative to
    	mode : Int32 # NotifyNormal, NotifyWhileGrabbed, NotifyGrab, NotifyUngrab
      detail : Int32
      # NotifyAncestor, NotifyVirtual, NotifyInferior,
      # NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
      # NotifyPointerRoot, NotifyDetailNone
    end

    alias PFocusInEvent = FocusInEvent*
    alias FocusInEvent = FocusChangeEvent

    alias PFocusOutEvent = FocusOutEvent*
    alias FocusOutEvent = FocusChangeEvent

    # generated on EnterWindow and FocusIn  when KeyMapState selected
    alias PKeymapEvent = KeymapEvent*
    struct KeymapEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # "event" window reported relative to
    	key_vector : UInt8[32];
    end

    alias PExposeEvent = ExposeEvent*
    struct ExposeEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window
    	x, y : Int32
    	width, height : Int32
    	count : Int32 # if non-zero, at least this many more
    end

    alias PGraphicsExposeEvent = GraphicsExposeEvent*
    struct GraphicsExposeEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	drawable : Drawable
      x, y : Int32
    	width, height : Int32
    	count : Int32 # if non-zero, at least this many more
    	major_code : Int32 # core is CopyArea or CopyPlane
      minor_code : Int32 # not defined in the core
    end

    alias PNoExposeEvent = NoExposeEvent*
    struct NoExposeEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	drawable : Drawable
      major_code : Int32 # core is CopyArea or CopyPlane
      minor_code : Int32 # not defined in the core
    end

    alias PVisibilityEvent = VisibilityEvent*
    struct VisibilityEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	window : Window
    	state : Int32 # Visibility state
    end

    alias PCreateWindowEvent = CreateWindowEvent*
    struct CreateWindowEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	parent : Window # parent of the window
      window : Window # window id of window created
      x, y : Int32 # window location
      width, height : Int32 # size of window
      border_width : Int32 # border width
      override_redirect : Bool # creation should be overridden
    end

    alias PDestroyWindowEvent = DestroyWindowEvent*
    struct DestroyWindowEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
      window : Window
    end

    alias PUnmapEvent = UnmapEvent*
    struct UnmapEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
      window : Window
    	from_configure : Bool
    end

    alias PMapEvent = MapEvent*
    struct MapEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
      window : Window
    	override_redirect : Bool # boolean, is override set...
    end

    alias PMapRequestEvent = MapRequestEvent*
    struct MapRequestEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	parent : Window
      window : Window
    end

    alias PReparentEvent = ReparentEvent*
    struct ReparentEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
    	window : Window
    	parent : Window
    	x, y : Int32
      override_redirect : Bool
    end

    alias PConfigureEvent = ConfigureEvent*
    struct ConfigureEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
    	window : Window
    	x, y : Int32
      width, height : Int32
      border_width : Int32
      above : Window
      override_redirect : Bool
    end

    alias PGravityEvent = GravityEvent*
    struct GravityEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	event : Window
    	window : Window
    	x, y : Int32
    end

    alias PResizeRequestEvent = ResizeRequestEvent*
    struct ResizeRequestEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	window : Window
      width, height : Int32
    end

    alias PConfigureRequestEvent = ConfigureRequestEvent*
    struct ConfigureRequestEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	parent : Window
      window : Window
    	x, y : Int32
      width, height : Int32
      border_width : Int32
      above : Window
      detail : Int32 # Above, Below, TopIf, BottomIf, Opposite
      value_mask : UInt64
    end

    alias PCirculateEvent = CirculateEvent*
    struct CirculateEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	parent : Window
      window : Window
    	place : Int32 # PlaceOnTop, PlaceOnBottom
    end

    alias PCirculateRequestEvent = CirculateRequestEvent*
    struct CirculateRequestEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	parent : Window
      window : Window
    	place : Int32 # PlaceOnTop, PlaceOnBottom
    end

    alias PPropertyEvent = PropertyEvent*
    struct PropertyEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	window : Window
      atom : Atom
      time : Time
      state : Int32 # NewValue, Deleted
    end

    alias PSelectionClearEvent = SelectionClearEvent*
    struct SelectionClearEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
    	window : Window
      selection : Atom
      time : Time
    end

    alias PSelectionRequestEvent = SelectionRequestEvent*
    struct SelectionRequestEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      owner : Window
      requestor : Window
      selection : Atom
      target : Atom
      property : Atom
      time : Time
    end

    alias PSelectionEvent = SelectionEvent*
    struct SelectionEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      requestor : Window
      selection : Atom
      target : Atom
    	property : Atom # ATOM or None
      time : Time
    end

    alias PColormapEvent = ColormapEvent*
    struct ColormapEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window
      colormap : Colormap # COLORMAP or None
      c_new : Bool
      state : Int32 # ColormapInstalled, ColormapUninstalled
    end

    union ClientMessageEvent_Data
      b : UInt8[20]
      s : Int16[10]
      l : Int64[5]
    end

    alias PClientMessageEvent = ClientMessageEvent*
    struct ClientMessageEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window
      message_type : Atom
      format : Int32
      data : ClientMessageEvent_Data
    end

    alias PMappingEvent = MappingEvent*
    struct MappingEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # unused
      request : Int32 # one of MappingModifier, MappingKeyboard, MappingPointer
      first_keycode : Int32 # first keycode
      count : Int32 # defines range of change w. first_keycode
    end

    alias PErrorEvent = ErrorEvent*
    struct ErrorEvent
      type : Int32
      display : PDisplay # Display the event was read from
      resourceid : XID # resource id
      serial : UInt64 # serial number of failed request
      error_code : UInt8 # error code of failed request
      request_code : UInt8 # Major op-code of failed request
      minor_code : UInt8 # Minor op-code of failed request
    end

    alias PAnyEvent = AnyEvent*
    struct AnyEvent
      type : Int32
      serial : UInt64 # # of last request processed by server
      send_event : Bool # true if this came from a SendEvent request
      display : PDisplay # Display the event was read from
      window : Window # window on which event was requested in event mask
    end

    #***************************************************************
    #
    # GenericEvent.  This event is the standard event for all newer extensions.


    alias PGenericEvent = GenericEvent*
    struct GenericEvent
      type       : Int32    # of event. Always GenericEvent
      serial     : UInt64   # # of last request processed
      send_event : Bool     # true if from SendEvent request
      display    : PDisplay # Display the event was read from
      extension  : Int32    # major opcode of extension that caused the event
      evtype     : Int32    # actual event type.
    end

    alias PGenericEventCookie = GenericEventCookie*
    struct GenericEventCookie
      type       : Int32    # of event. Always GenericEvent
      serial     : UInt64   # # of last request processed
      send_event : Bool     # true if from SendEvent request
      display    : PDisplay # Display the event was read from
      extension  : Int32    # major opcode of extension that caused the event
      evtype     : Int32    # actual event type.
      cookie     : UInt32
      data       : Void*
    end

    # this union is defined so Xlib can always use the same sized
    # event structure internally, to avoid memory fragmentation.
    alias PEvent = Event*
    union Event
      type : Int32 # must not be changed; first element
      any : AnyEvent
      key : KeyEvent
      button : ButtonEvent
      motion : MotionEvent
      crossing : CrossingEvent
      focus : FocusChangeEvent
      expose : ExposeEvent
      graphicsexpose : GraphicsExposeEvent
      noexpose : NoExposeEvent
      visibility : VisibilityEvent
      createwindow : CreateWindowEvent
      destroywindow : DestroyWindowEvent
      unmap : UnmapEvent
      map : MapEvent
      maprequest : MapRequestEvent
      reparent : ReparentEvent
      configure : ConfigureEvent
      gravity : GravityEvent
      resizerequest : ResizeRequestEvent
      configurerequest : ConfigureRequestEvent
      circulate : CirculateEvent
      circulaterequest : CirculateRequestEvent
      property : PropertyEvent
      selectionclear : SelectionClearEvent
      selectionrequest : SelectionRequestEvent
      selection : SelectionEvent
      colormap : ColormapEvent
      client : ClientMessageEvent
      mapping : MappingEvent
      error : ErrorEvent
      keymap : KeymapEvent
      generic : GenericEvent
      cookie : GenericEventCookie
      pad : Int64[24];
    end

    # per character font metric information.
    alias PCharStruct = CharStruct*
    struct CharStruct
      lbearing : Int16 # origin to left edge of raster
      rbearing : Int16 # origin to right edge of raster
      width : Int16 # advance to next char's origin
      ascent : Int16 # baseline to top edge of raster
      descent : Int16 # baseline to bottom edge of raster
      attributes : UInt16 # per char flags (not predefined)
    end

    # To allow arbitrary information with fonts, there are additional properties returned.
    alias PFontProp = FontProp*
    struct FontProp
      name : Atom
      card32 : UInt64
    end

    alias PFontStruct = FontStruct*
    struct FontStruct
      ext_data : PExtData # hook for extension to hang data
      fid : Font # Font id for this font
      direction : UInt32 # hint about direction the font is painted
      min_char_or_char2 : UInt32 # first character
      max_char_or_char2 : UInt32 # last character
      min_char1 : UInt32 # first row that exists
      max_char1 : UInt32 # last row that exists
      all_chars_exist : Bool # flag if all characters have non-zero size
      default_char : UInt32 # char to print for undefined character
      n_properties : Int32 # how many properties there are
      properties : PFontProp # pointer to array of additional properties
      min_bounds : CharStruct # minimum bounds over all existing char
      max_bounds : CharStruct #  maximum bounds over all existing char
      per_char : PCharStruct # first_char to last_char information
      ascent : Int32 # log. extent above baseline for spacing
      descent : Int32 # log. descent below baseline for spacing
    end

    fun load_query_font = XLoadQueryFont(display : PDisplay, name : PChar) : PFontStruct
    fun query_font = XQueryFont(display : PDisplay, fint_id : XID) : PFontStruct
    fun get_motion_events = XGetMotionEvents(display : PDisplay, w : Window, start : Time, stop : Time, nevents_return : PInt32) : PTimeCoord
    fun delete_modifiermap_entry = XDeleteModifiermapEntry(modmap : PModifierKeymap, keycode_entry : KeyCode, modifier : Int32) : PModifierKeymap
    fun get_modifier_mapping = XGetModifierMapping(display : PDisplay) : PModifierKeymap
    fun insert_modifier_entry = XInsertModiferEntry(modmap : PModifierKeymap, keycode_entry : KeyCode, modifier : Int32) : PModifierKeymap
    fun new_modifier_map = XNewModifierMap(max_keys_per_mod : Int32) : PModifierKeymap
    fun create_image = XCreateImage(display : PDisplay, visual : PVisual, depth : UInt32, format : Int32, offset : Int32, data : PChar, width : UInt32, height : UInt32, bitmap_pad : Int32, bytes_per_line : Int32) : PImage
    fun init_image = XInitImage(image : PImage) : Status
    fun get_image = XGetImage(display : PDisplay, d : Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32) : PImage
    fun get_sub_image = XGetSubImage(display : PDisplay, d : Drawable, x : Int32, y : Int32, width : UInt32, height : UInt32, plane_mask : UInt64, format : Int32, dest_image : PImage, dest_x : Int32, dest_y : Int32) : PImage

    # X function declarations.

    fun open_display = XOpenDisplay(display_name : PChar) : PDisplay
    fun rm_initialize = XrmInitialize() : NoReturn
    fun fetch_bytes = XFetchBytes(display : PDisplay, nbytes_return : PInt32) : PChar
    fun fetch_buffer = XFetchBuffer(display : PDisplay, nbytes_return : PInt32, buffer : Int32) : PChar
    fun get_atom_name = XGetAtomName(display : PDisplay, atom : Atom) : PChar
    fun get_atom_names = XGetAtomNames(dpy : PDisplay, atoms : PAtom, count : Int32, names_return : PPChar) : Status
    fun get_default = XGetDefault(display : PDisplay, program : PChar, option : PChar) : PChar
    fun display_name = XDisplayName(string : PChar) : PChar
    fun keysym_to_string = XKeysymToString(keysym : KeySym) : PChar
  end # lib Xlib

  Xlib._Xdebug = 0
end # module X11

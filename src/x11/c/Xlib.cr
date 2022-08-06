require "./X"

module X11::C
  @[Link("X11")]
  lib X
    alias Pointer = UInt8*
    alias Status = Int32
    alias PStatus = Status*

    alias PBool = Bool*
    alias Bool = Int32
    True = 1
    False = 0

    alias WCharT = UInt64
    alias PWCharT = WCharT*

    $_Xdebug : Int32

    # Returns the number of characters pointed to by "str". Only "len" bytes in "str" are used in determining the character count returned. "Str" may point at characters from any valid codeset in the current locale.
    fun mblen = _Xmblen(
      str : PChar,
      len : Int32
    ) : Int32

    # API mentioning "UTF8" or "utf8" is an XFree86 extension, introduced in
    # November 2000. Its presence is indicated through the following macro.
    X_HAVE_UTF8_STRING = 1

    QueuedAlready      = 0
    QueuedAfterReading = 1
    QueuedAfterFlush   = 2

    # Extensions need a way to hang private data on some structures.
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
    alias PrmHashBucketRec = Pointer

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
      db : PrmHashBucketRec
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
      ul : UInt64[5]
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

    # PolyText routines take these as arguments.

    alias PTextItem = TextItem*
    struct TextItem
      chars : PChar # pointer to string
      nchars : Int32 # number of characters
      delta : Int32 # delta between strings
      font : Font # font to print it in, None don't change
    end

    alias PChar2b = Char2b*
    struct Char2b # normal 16 bit characters are two bytes
      byte1 : UInt8
      byte2 : UInt8
    end

    alias PTextItem16 = TextItem16*
    struct TextItem16
      chars : PChar2b # two byte characters
      nchars : Int32 # number of characters
      delta : Int32 # delta between strings
      font : Font # font to print it in, None don't change
    end

    alias PEDataObject = EDataObject*
    union EDataObject
      display : PDisplay
      dc : GC
      visual : PVisual
      screen : PScreen
      pixmap_format : PScreenFormat
      font : PFontStruct
    end

    alias PFontSetExtents = FontSetExtents*
    struct FontSetExtents
      max_ink_extent : Rectangle
      max_logical_extent : Rectangle
    end

    # unused:
    # alias OMProc = () -> NoReturn

    alias XOM = Pointer
    alias XOC = Pointer
    alias FontSet = Pointer

    alias PmbTextItem = XmbTextItem*
    struct XmbTextItem
      chars : PChar
      nchars : Int32
      delta : Int32
      font_set : FontSet
    end

    alias PwcTextItem = XwcTextItem*
    struct XwcTextItem
      chars : PWCharT
      nchars : Int32
      delta : Int32
      font_set : FontSet
    end

    NRequiredCharSet = "requiredCharSet"
    NQueryOrientation = "queryOrientation"
    NBaseFontName = "baseFontName"
    NOMAutomatic = "omAutomatic"
    NMissingCharSet = "missingCharSet"
    XNDefaultString = "defaultString"
    XNOrientation = "orientation"
    XNDirectionalDependentDrawing = "directionalDependentDrawing"
    XNContextualDrawing = "contextualDrawing"
    XNFontInfo = "fontInfo"

    alias POMCharSetList = OMCharSetList*
    struct OMCharSetList
      charset_count : Int32
      charset_list : PPChar
    end

    alias POrientation = Orientation*
    enum Orientation
      OMOrientation_LTR_TTB
      OMOrientation_RTL_TTB
      OMOrientation_TTB_LTR
      OMOrientation_TTB_RTL
      OMOrientation_Context
    end

    alias POMOrientation = OMOrientation*
    struct OMOrientation
      num_orientation : Int32
      orientation : POrientation # Input Text description
    end

    alias POMFontInfo = OMFontInfo*
    struct OMFontInfo
      num_font : Int32
      font_struct_list : PFontStruct*
      font_name_list : PPChar
    end

    alias XIM = Pointer*
    alias XIC = Pointer*

    alias IMProc = XIM, Pointer, Pointer -> Bool

    alias ICProc = XIC, Pointer, Pointer -> Bool

    alias IDProc = PDisplay, Pointer, Pointer -> NoReturn

    alias PIMStyle = IMStyle*
    alias IMStyle = UInt64

    alias PIMStyles = IMStyles*
    struct IMStyles
      count_styles : UInt16
      supported_styles : PIMStyle
    end

    IMPreeditArea = 0x0001_i64
    IMPreeditCallbacks = 0x0002_i64
    IMPreeditPosition = 0x0004_i64
    IMPreeditNothing = 0x0008_i64
    IMPreeditNone = 0x0010_i64
    IMStatusArea = 0x0100_i64
    IMStatusCallbacks = 0x0200_i64
    IMStatusNothing = 0x0400_i64
    IMStatusNone = 0x0800_i64

    NVaNestedList = "XNVaNestedList"
    NQueryInputStyle = "queryInputStyle"
    NClientWindow = "clientWindow"
    NInputStyle = "inputStyle"
    NFocusWindow = "focusWindow"
    NResourceName = "resourceName"
    NResourceClass = "resourceClass"
    NGeometryCallback = "geometryCallback"
    NDestroyCallback = "destroyCallback"
    NFilterEvents = "filterEvents"
    NPreeditStartCallback = "preeditStartCallback"
    NPreeditDoneCallback = "preeditDoneCallback"
    NPreeditDrawCallback = "preeditDrawCallback"
    NPreeditCaretCallback = "preeditCaretCallback"
    NPreeditStateNotifyCallback = "preeditStateNotifyCallback"
    NPreeditAttributes = "preeditAttributes"
    NStatusStartCallback = "statusStartCallback"
    NStatusDoneCallback = "statusDoneCallback"
    NStatusDrawCallback = "statusDrawCallback"
    NStatusAttributes = "statusAttributes"
    NArea = "area"
    NAreaNeeded = "areaNeeded"
    NSpotLocation = "spotLocation"
    NColormap = "colorMap"
    NStdColormap = "stdColorMap"
    NForeground = "foreground"
    NBackground = "background"
    NBackgroundPixmap = "backgroundPixmap"
    NFontSet = "fontSet"
    NLineSpace = "lineSpace"
    NCursor = "cursor"

    NQueryIMValuesList = "queryIMValuesList"
    NQueryICValuesList = "queryICValuesList"
    NVisiblePosition = "visiblePosition"
    NR6PreeditCallback = "r6PreeditCallback"
    NStringConversionCallback = "stringConversionCallback"
    NStringConversion = "stringConversion"
    NResetState = "resetState"
    NHotKey = "hotKey"
    NHotKeyState = "hotKeyState"
    NPreeditState = "preeditState"
    NSeparatorofNestedList = "separatorofNestedList"

    BufferOverflow = -1
    LookupNone = 1
    LookupChars = 2
    LookupKeySym = 3
    LookupBoth = 4

    alias PVaNestedList = VaNestedList*
    alias VaNestedList = Void*

    alias PIMCallback = IMCallback*
    struct IMCallback
      client_data : Pointer
      callback : IMProc
    end

    alias PICCallback = ICCallback*
    struct ICCallback
      client_data : Pointer
      callback : ICProc
    end

    alias PIMFeedback = IMFeedback*
    alias IMFeedback = UInt64

    IMReverse = 1_i64
    IMUnderline = (1_i64 << 1)
    IMHighlight = (1_i64 << 2)
    IMPrimary = (1_i64 << 5)
    IMSecondary = (1_i64 << 6)
    IMTertiary = (1_i64 << 7)
    IMVisibleToForward = (1_i64 << 8)
    IMVisibleToBackword = (1_i64 << 9)
    IMVisibleToCenter = (1_i64 << 10)

    struct IM_Text_string
      multi_byte : PChar
      wide_char : PWCharT
    end

    alias PIMText = IMText*
    struct IMText
      length : UInt16
      feedback : PIMFeedback
      encoding_is_wchar : Bool
      string : IM_Text_string
    end

    alias PIMPreeditState = IMPreeditState*
    alias IMPreeditState = UInt64

    IMPreeditUnKnown = 0_i64
    IMPreeditEnable = 1_i64
    IMPreeditDisable = (1_i64 << 1)

    alias PIMPreeditStateNotifyCallbackStruct = IMPreeditStateNotifyCallbackStruct*
    struct IMPreeditStateNotifyCallbackStruct
      state : IMPreeditState
    end

    alias PIMResetState = IMResetState*
    alias IMResetState = UInt64

    IMInitialState  = 1_i64
    IMPreserveState = (1_i64 << 1)

    alias PIMStringConversionFeedback = IMStringConversionFeedback*
    alias IMStringConversionFeedback = UInt64

    IMStringConversionLeftEdge   = (0x00000001)
    IMStringConversionRightEdge  = (0x00000002)
    IMStringConversionTopEdge    = (0x00000004)
    IMStringConversionBottomEdge = (0x00000008)
    IMStringConversionConcealed  = (0x00000010)
    IMStringConversionWrapped    = (0x00000020)

    union IMStringConversionText_string
      mbs : PChar
      wcs: PWCharT
    end

    alias PIMStringConversionText = IMStringConversionText*
    struct IMStringConversionText
      length : UInt16
      feedback : PIMStringConversionFeedback
      encoding_is_wchar : Bool
      string : IMStringConversionText_string
    end

    alias PIMStringConversionPosition = IMStringConversionPosition*
    alias IMStringConversionPosition = UInt16

    alias PIMStringConversionType = IMStringConversionType*
    alias IMStringConversionType = UInt16

    IMStringConversionBuffer = (0x0001)
    IMStringConversionLine   = (0x0002)
    IMStringConversionWord   = (0x0003)
    IMStringConversionChar   = (0x0004)

    alias PIMStringConversionOperation = IMStringConversionOperation*
    alias IMStringConversionOperation = UInt16

    IMStringConversionSubstitution = (0x0001)
    IMStringConversionRetrieval    = (0x0002)

    enum IMCaretDirection
      IMForwardChar
      IMBackwardChar
      IMForwardWord
      IMBackwardWord
      IMCaretUp
      IMCaretDown
      IMNextLine
      IMPreviousLine
      IMLineStart
      IMLineEnd
      IMAbsolutePosition
      IMDontChange
    end

    alias PIMStringConversionCallbackStruct = IMStringConversionCallbackStruct*
    struct IMStringConversionCallbackStruct
      position : IMStringConversionPosition
      direction : IMCaretDirection
      operation : IMStringConversionOperation
      factor : UInt16
      text : PIMStringConversionText
    end

    alias PIMPreeditDrawCallbackStruct = IMPreeditDrawCallbackStruct*
    struct IMPreeditDrawCallbackStruct
      caret : Int32 # Cursor offset within pre-edit string
      chg_first : Int32 # Starting change position
      chg_length : Int32 # Length of the change in character count
      text : PIMText
    end

    enum IMCaretStyle
      IMIsInvisible # Disable caret feedback
      IMIsPrimary # UI defined caret feedback
      IMIsSecondary # UI defined caret feedback
    end

    alias PIMPreeditCaretCallbackStruct = IMPreeditCaretCallbackStruct*
    struct IMPreeditCaretCallbackStruct
      position : Int32 # Caret offset within pre-edit string
      direction : IMCaretDirection # Caret moves direction
      style : IMCaretStyle # Feedback of the caret
    end

    enum IMStatusDataType
      IMTextType
      IMBitmapType
    end

    union IMStatusDrawCallbackStruct_data
      text : PIMText
      bitmap : Pixmap
    end

    alias PIMStatusDrawCallbackStruct = IMStatusDrawCallbackStruct*
    struct IMStatusDrawCallbackStruct
      type : IMStatusDataType
      data : IMStatusDrawCallbackStruct_data
    end

    alias PIMHotKeyTrigger = IMHotKeyTrigger*
    struct IMHotKeyTrigger
      keysym : KeySym
      modifier : Int32
      modifier_mask : Int32
    end

    alias PIMHotKeyTriggers = IMHotKeyTriggers*
    struct IMHotKeyTriggers
      num_hot_key : Int32
      key : PIMHotKeyTrigger
    end

    alias PIMHotKeyState = IMHotKeyState*
    alias IMHotKeyState = UInt64

    IMHotKeyStateON  = (0x0001_i64)
    IMHotKeyStateOFF = (0x0002_i64)

    alias PIMValuesList = IMValuesList*
    struct IMValuesList
      count_values : UInt16
      supported_values : PPChar
    end

    fun load_query_font = XLoadQueryFont(
      display : PDisplay,
      name : PChar
    ) : PFontStruct

    fun query_font = XQueryFont(
      display : PDisplay,
      fint_id : XID
    ) : PFontStruct

    fun get_motion_events = XGetMotionEvents(
      display : PDisplay,
      w : Window,
      start : Time,
      stop : Time,
      nevents_return : PInt32
    ) : PTimeCoord

    fun delete_modifiermap_entry = XDeleteModifiermapEntry(
      modmap : PModifierKeymap,
      keycode_entry : KeyCode,
      modifier : Int32
    ) : PModifierKeymap

    fun get_modifier_mapping = XGetModifierMapping(
      display : PDisplay
    ) : PModifierKeymap

    fun insert_modifier_entry = XInsertModiferEntry(
      modmap : PModifierKeymap,
      keycode_entry : KeyCode,
      modifier : Int32
    ) : PModifierKeymap

    fun new_modifier_map = XNewModifierMap(
      max_keys_per_mod : Int32
    ) : PModifierKeymap

    fun create_image = XCreateImage(
      display : PDisplay,
      visual : PVisual,
      depth : UInt32,
      format : Int32,
      offset : Int32,
      data : PChar,
      width : UInt32,
      height : UInt32,
      bitmap_pad : Int32,
      bytes_per_line : Int32
    ) : PImage

    fun init_image = XInitImage(
      image : PImage
    ) : Status

    fun get_image = XGetImage(
      display : PDisplay,
      d : Drawable,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      plane_mask : UInt64,
      format : Int32
    ) : PImage

    fun get_sub_image = XGetSubImage(
      display : PDisplay,
      d : Drawable,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      plane_mask : UInt64,
      format : Int32,
      dest_image : PImage,
      dest_x : Int32,
      dest_y : Int32
    ) : PImage

    # X function declarations.

    fun open_display = XOpenDisplay(
      display_name : PChar
    ) : PDisplay

    fun rm_initialize = XrmInitialize() : NoReturn

    fun fetch_bytes = XFetchBytes(
      display : PDisplay,
      nbytes_return : PInt32
    ) : PChar

    fun fetch_buffer = XFetchBuffer(
      display : PDisplay,
      nbytes_return : PInt32,
      buffer : Int32
    ) : PChar

    fun get_atom_name = XGetAtomName(
      display : PDisplay,
      atom : Atom
    ) : PChar

    fun get_atom_names = XGetAtomNames(
      dpy : PDisplay,
      atoms : PAtom,
      count : Int32,
      names_return : PPChar
    ) : Status

    fun get_default = XGetDefault(
      display : PDisplay,
      program : PChar,
      option : PChar
    ) : PChar

    fun display_name = XDisplayName(
      string : PChar
    ) : PChar

    fun keysym_to_string = XKeysymToString(
      keysym : KeySym
    ) : PChar

    fun synchronize = XSynchronize(
      display : PDisplay,
      onoff : Bool
    ) : PDisplay -> Int32

    fun set_after_function = XSetAfterFunction(
      display : PDisplay,
      procedure : PDisplay -> Int32
    ) : Int32

    fun intern_atom = XInternAtom(
      display : PDisplay,
      atom_name : PChar,
      only_if_exists : Bool
    ) : Atom

    fun intern_atoms = XInternAtoms(
      dpy : PDisplay,
      names : PPChar,
      count : Int32,
      onlyIfExists : Bool,
      atoms_return : PAtom
    ) : Status

    fun copy_colormap_and_free = XCopyColormapAndFree(
      display : PDisplay,
      colormap : Colormap
    ) : Colormap

    fun create_colormap = XCreateColormap(
      display : PDisplay,
      w : Window,
      visual : PVisual,
      alloc : Int32
    ) : Colormap

    fun create_pixmap_cursor = XCreatePixmapCursor(
      display : PDisplay,
      source : Pixmap,
      mask : Pixmap,
      foreground_color : PColor,
      background_color : PColor,
      x : UInt32,
      y : UInt32
    ) : Cursor

    fun create_glyph_cursor = XCreateGlyphCursor(
      display : PDisplay,
      source_font : Font,
      mask_font : Font,
      source_char : UInt32,
      mask_char : UInt32,
      foreground_color : PColor,
      background_color : PColor
    ) : Cursor

    fun create_font_cursor = XCreateFontCursor(
      display : PDisplay,
      shape : UInt32
    ) : Cursor

    fun load_font = XLoadFont(
      display : PDisplay,
      name : PChar
    ) : Font

    fun create_gc = XCreateGC(
      display : PDisplay,
      d : Drawable,
      valuemask : UInt64,
      values : PGCValues
    ) : GC

    fun g_context_from_gc = XGContextFromGC(
      gc : GC
    ) : GContext

    fun flush_gc = XFlushGC(
      display : PDisplay,
      gc : GC
    ) : NoReturn

    fun create_pixmap = XCreatePixmap(
      display : PDisplay,
      d : Drawable,
      width : UInt32,
      height : UInt32,
      depth : UInt32
    ) : Pixmap

    fun create_bitmap_from_data = XCreateBitmapFromData(
      display : PDisplay,
      d : Drawable,
      data : PChar,
      width : UInt32,
      height : UInt32
    ) : Pixmap

    fun create_pixmap_from_bitmap_data = XCreatePixmapFromBitmapData(
      display : PDisplay,
      d : Drawable,
      data : PChar,
      width : UInt32,
      height : UInt32,
      fg : UInt64,
      bg : UInt64,
      depth : UInt64
    ) : Pixmap

    fun create_simple_window = XCreateSimpleWindow(
      display : PDisplay,
      parent : Window,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      border_width : UInt32,
      border : UInt64,
      background : UInt64
    ) : Window

    fun get_selection_owner = XGetSelectionOwner(
      display : PDisplay,
      selection : Atom,
    ) : Window;

    fun create_window = XCreateWindow(
      display : PDisplay,
      parent : Window,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      border_width : UInt32,
      depth : Int32,
      c_class : UInt32,
      visual : PVisual,
      valuemask : UInt64,
      attributes : PSetWindowAttributes
    ) : Window

    fun list_installed_colormaps = XListInstalledColormaps(
      display : PDisplay,
      w : Window,
      num_return : PInt32
    ) : PColormap

    fun list_fonts = XListFonts(
      display : PDisplay,
      pattern : PChar,
      maxnames : Int32,
      actual_count_return : PInt32
    ) : PPChar

    fun list_fonts_with_info = XListFontsWithInfo(
      display : PDisplay,
      pattern : PChar,
      maxnames : Int32,
      count_return : PInt32,
      info_return : PFontStruct*
    ) : PPChar

    fun get_font_path = XGetFontPath(
      display : PDisplay,
      npaths_return : PInt32
    ) : PPChar

    fun list_extensions = XListExtensions(
      display : PDisplay,
      nextensions_return : PInt32
    ) : PPChar

    fun list_properties = XListProperties(
      display : PDisplay,
      w : Window,
      num_prop_return : PInt32
    ) : PAtom

    fun list_hosts = XListHosts(
      display : PDisplay,
      nhosts_return : PInt32,
      state_return : PBool
    ) : PHostAddress

    fun keycode_to_keysym = XKeycodeToKeysym(
      display : PDisplay,
      keycode : KeyCode,
      index : Int32
    ) : KeySym

    fun lookup_keysym = XLookupKeysym(
      key_event : PKeyEvent,
      index : Int32
    ) : KeySym

    fun get_keyboard_mapping = XGetKeyboardMapping(
      display : PDisplay,
      first_keycode : KeyCode,
      keycode_count : Int32,
      keysyms_per_keycode_return : PInt32
    ) : PKeySym

    fun string_to_keysym = XStringToKeysym(
      string : PChar
    ) : KeySym

    fun max_request_size = XMaxRequestSize(
      display : PDisplay
    ) : Int64

    fun extended_max_request_size = XExtendedMaxRequestSize(
      display : PDisplay
    ) : Int64

    fun resource_manager_string = XResourceManagerString(
      display : PDisplay
    ) : PChar

    fun screen_resource_string = XScreenResourceString(
      screen : PScreen
    ) : PChar

    fun display_motion_buffer_size = XDisplayMotionBufferSize(
      display : PDisplay
    ) : UInt64

    fun visual_id_from_visual = XVisualIDFromVisual(
      visual : PVisual
    ) : VisualID

    # multithread routines

    fun init_threads = XInitThreads() : Status

    fun lock_display = XLockDisplay(
      display : PDisplay
    ) : NoReturn

    fun unlock_display = XUnlockDisplay(
      display : PDisplay
    ) : NoReturn

    # routines for dealing with extensions

    fun init_extension = XInitExtension(
      display : PDisplay,
      name : PChar
    ) : PExtCodes

    fun add_extension = XAddExtension(
      display : PDisplay
    ) : PExtCodes

    fun find_on_extension_list = XFindOnExtensionList(
      structure : PExtData*,
      number : Int32
    ) : PExtData

    fun e_head_of_extension_list = XEHeadOfExtensionList(
      object : EDataObject
    ) : PExtData*

    # these are routines for which there are also macros
    fun root_window = XRootWindow(
      display : PDisplay,
      screen_number : Int32
    ) : Window

    fun default_root_window = XDefaultRootWindow(
      display : PDisplay
    ) : Window

    fun root_window_of_screen = XRootWindowOfScreen(
      screen : PScreen
    ) : Window

    fun default_visual = XDefaultVisual(
      display : PDisplay,
      screen_number : Int32
    ) : PVisual

    fun default_visual_of_screen = XDefaultVisualOfScreen(
      screen : PScreen
    ) : PVisual

    fun default_gc = XDefaultGC(
      display : PDisplay,
      screen_number : Int32
    ) : GC

    fun default_gc_of_screen = XDefaultGCOfScreen(
      screen : PScreen
    ) : GC

    fun black_pixel = XBlackPixel(
      display : PDisplay,
      screen_number : Int32
    ) : UInt64

    fun white_pixel = XWhitePixel(
      display : PDisplay,
      screen_number : Int32
    ) : UInt64

    fun all_planes = XAllPlanes() : UInt64

    fun black_pixel_of_screen = XBlackPixelOfScreen(
      screen : PScreen
    ) : UInt64

    fun white_pixel_of_screen = XWhitePixelOfScreen(
      screen : PScreen
    ) : UInt64

    fun next_request = XNextRequest(
      display : PDisplay
    ) : UInt64

    fun last_known_request_processed = XLastKnownRequestProcessed(
      display : PDisplay
    ) : UInt64

    fun server_vendor = XServerVendor(
      display : PDisplay
    ) : PChar

    fun display_string = XDisplayString(
      display : PDisplay
    ) : PChar

    fun default_colormap = XDefaultColormap(
      display : PDisplay,
      screen_number : Int32
    ) : Colormap

    fun default_colormap_of_screen = XDefaultColormapOfScreen(
      screen : PScreen
    ) : Colormap

    fun display_of_screen = XDisplayOfScreen(
      screen : PScreen
    ) : PDisplay

    fun screen_of_display = XScreenOfDisplay(
      display : PDisplay,
      screen_number : Int32
    ) : PScreen

    fun default_screen_of_display = XDefaultScreenOfDisplay(
      display : PDisplay
    ) : PScreen

    fun event_mask_of_screen = XEventMaskOfScreen(
      screen : PScreen
    ) : Int64

    fun screen_number_of_screen = XScreenNumberOfScreen(
      screen : PScreen
    ) : Int32

    # WARNING, this type not in Xlib spec
    alias ErrorHandler = PDisplay, PErrorEvent -> Int32

    fun set_error_handler = XSetErrorHandler(
      handler : ErrorHandler
    ) : ErrorHandler

    # WARNING, this type not in Xlib spec
    alias IOErrorHandler = PDisplay -> Int32

    fun set_io_error_handler = XSetIOErrorHandler(
      handler : IOErrorHandler
    ) : IOErrorHandler

    fun list_pixmap_formats = XListPixmapFormats(
      display : PDisplay,
      count_return : PInt32
    ) : PPixmapFormatValues

    fun list_depths = XListDepths(
      display : PDisplay,
      screen_number : Int32,
      count_return : PInt32
    ) : PInt32

    # ICCCM routines for things that don't require special include files;
    # other declarations are given in Xutil.h
    fun reconfigure_wm_window = XReconfigureWMWindow(
      display : PDisplay,
      w : Window,
      screen_number : Int32,
      mask : UInt32,
      changes : PWindowChanges
    ) : Status

    fun get_wm_protocols = XGetWMProtocols(
      display : PDisplay,
      w : Window,
      protocols_return : PAtom*,
      count_return : PInt32
    ) : Status

    fun set_wm_protocols = XSetWMProtocols(
      display : PDisplay,
      w : Window,
      protocols : PAtom,
      count : Int32
    ) : Status

    fun iconify_window = XIconifyWindow(
      display : PDisplay,
      w : Window,
      screen_number : Int32
    ) : Status

    fun withdraw_window = XWithdrawWindow(
      display : PDisplay,
      w : Window,
      screen_number : Int32
    ) : Status

    fun get_command = XGetCommand(
      display : PDisplay,
      w : Window,
      argv_return : PPChar*,
      argc_return : PInt32
    ) : Status

    fun get_wm_colormap_windows = XGetWMColormapWindows(
      display : PDisplay,
      w : Window,
      windows_return : Window**,
      count_return : PInt32
    ) : Status

    fun set_wm_colormap_windows = XSetWMColormapWindows(
      display : PDisplay,
      w : Window,
      colormap_windows : PWindow,
      count : Int32
    ) : Status

    fun free_string_list = XFreeStringList(
      list : PPChar
    ) : NoReturn

    fun set_transient_for_hint = XSetTransientForHint(
      display : PDisplay,
      w : Window,
      prop_window : Window
    ) : Int32

    # The following are given in alphabetical order

    fun activate_screen_saver = XActivateScreenSaver(
      display : PDisplay
    ) : Int32

    fun add_host = XAddHost(
      display : PDisplay,
      host : PHostAddress
    ) : Int32

    fun add_hosts = XAddHosts(
      display : PDisplay,
      hosts : PHostAddress,
      num_hosts : Int32
    ) : Int32

    fun add_to_extension_list = XAddToExtensionList(
      structure : PExtData*,
      ext_data : PExtData
    ) : Int32

    fun add_to_save_set = XAddToSaveSet(
      display : PDisplay,
      w : Window
    ) : Int32

    fun alloc_color = XAllocColor(
      display : PDisplay,
      colormap : Colormap,
      screen_in_out : PColor
    ) : Status

    fun alloc_color_cells = XAllocColorCells(
      display : PDisplay,
      colormap : Colormap,
      contig : Bool,
      plane_masks_return : PUInt64,
      nplanes : UInt32,
      pixels_return : PUInt64,
      npixels : UInt32
    ) : Status

    fun alloc_color_planes = XAllocColorPlanes(
      display : PDisplay,
      colormap : Colormap,
      contig : Bool,
      pixels_return : PUInt64,
      ncolors : Int32,
      nreds : Int32,
      ngreens : Int32,
      nblues : Int32,
      rmask_return : PUInt64,
      gmask_return : PUInt64,
      bmask_return : PUInt64
    ) : Status

    fun alloc_named_color = XAllocNamedColor(
      display : PDisplay,
      colormap : Colormap,
      color_name : PChar,
      screen_def_return : PColor,
      exact_def_return : PColor
    ) : Status

    fun allow_events = XAllowEvents(
      display : PDisplay,
      event_mode : Int32,
      time : Time
    ) : Int32

    fun auto_repeat_off = XAutoRepeatOff(
      display : PDisplay
    ) : Int32

    fun auto_repeat_on = XAutoRepeatOn(
      display : PDisplay
    ) : Int32

    fun bell = XBell(
      display : PDisplay,
      percent : Int32
    ) : Int32

    fun bitmap_bit_order = XBitmapBitOrder(
      display : PDisplay
    ) : Int32

    fun bitmap_pad = XBitmapPad(
      display : PDisplay
    ) : Int32

    fun bitmap_unit = XBitmapUnit(
      display : PDisplay
    ) : Int32

    fun cells_of_screen = XCellsOfScreen(
      screen : PScreen
    ) : Int32

    fun change_active_pointer_grab = XChangeActivePointerGrab(
      display : PDisplay,
      event_mask : UInt32,
      cursor : Cursor,
      time : Time
    ) : Int32

    fun change_gc = XChangeGC(
      display : PDisplay,
      gc : GC,
      valuemask : UInt64,
      values : PGCValues
    ) : Int32

    fun change_keyboard_control = XChangeKeyboardControl(
      display : PDisplay,
      value_mask : UInt64,
      values : PKeyboardControl
    ) : Int32

    fun change_keyboard_mapping = XChangeKeyboardMapping(
      display : PDisplay,
      first_keycode : Int32,
      keysyms_per_keycode : Int32,
      keysyms : PKeySym,
      num_codes : Int32
    ) : Int32

    fun change_pointer_control = XChangePointerControl(
      display : PDisplay,
      do_accel : Bool,
      do_threshold : Bool,
      accel_numerator : Int32,
      accel_denominator : Int32,
      threshold : Int32
    ) : Int32

    fun change_property = XChangeProperty(
      display : PDisplay,
      w : Window,
      property : Atom,
      type : Atom,
      format : Int32,
      mode : Int32,
      data : PChar,
      nelements : Int32
    ) : Int32

    fun change_save_set = XChangeSaveSet(
      display : PDisplay,
      w : Window,
      change_mode : Int32
    ) : Int32

    fun change_window_attributes = XChangeWindowAttributes(
      display : PDisplay,
      w : Window,
      valuemask : UInt64,
      attributes : PSetWindowAttributes
    ) : Int32

    fun check_if_event = XCheckIfEvent(
      display : PDisplay,
      event_return : PEvent,
      predicate : PDisplay, PEvent, Pointer -> Bool,
      arg : Pointer
    ) : Bool

    fun check_mask_event = XCheckMaskEvent(
      display : PDisplay,
      event_mask : Int64,
      event_return : PEvent
    ) : Bool

    fun check_typed_event = XCheckTypedEvent(
      display : PDisplay,
      event_type : Int32,
      event_return : PEvent
    ) : Bool

    fun check_typed_window_event = XCheckTypedWindowEvent(
      display : PDisplay,
      w : Window,
      event_type : Int32,
      event_return : PEvent
    ) : Bool

    fun check_window_event = XCheckWindowEvent(
      display : PDisplay,
      w : Window,
      event_mask : Int64,
      event_return : PEvent
    ) : Bool

    fun circulate_subwindows = XCirculateSubwindows(
      display : PDisplay,
      w : Window,
      direction : Int32
    ) : Int32

    fun circulate_subwindows_down = XCirculateSubwindowsDown(
      display : PDisplay,
      w : Window
    ) : Int32

    fun circulate_subwindows_up = XCirculateSubwindowsUp(
      display : PDisplay,
      w : Window
    ) : Int32

    fun clear_area = XClearArea(
      display : PDisplay,
      w : Window,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      exposures : Bool
    ) : Int32

    fun clear_window = XClearWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun close_display = XCloseDisplay(
      display : PDisplay
    ) : Int32

    fun configure_window = XConfigureWindow(
      display : PDisplay,
      w : Window,
      value_mask : UInt32,
      values : PWindowChanges
    ) : Int32

    fun connection_number = XConnectionNumber(
      display : PDisplay
    ) : Int32

    fun convert_selection = XConvertSelection(
      display : PDisplay,
      selection : Atom,
      target : Atom,
      property : Atom,
      requestor : Window,
      time : Time
    ) : Int32

    fun copy_area = XCopyArea(
      display : PDisplay,
      src : Drawable,
      dest : Drawable,
      gc : GC,
      src_x : Int32,
      src_y : Int32,
      width : UInt32,
      height : UInt32,
      dest_x : Int32,
      dest_y : Int32
    ) : Int32

    fun copy_gc = XCopyGC(
      display : PDisplay,
      src : GC,
      valuemask : UInt64,
      dest : GC
    ) : Int32

    fun copy_plane = XCopyPlane(
      display : PDisplay,
      src : Drawable,
      dest : Drawable,
      gc : GC,
      src_x : Int32,
      src_y : Int32,
      width : UInt32,
      height : UInt32,
      dest_x : Int32,
      dest_y : Int32,
      plane : UInt64
    ) : Int32

    fun default_depth = XDefaultDepth(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun default_depth_of_screen = XDefaultDepthOfScreen(
      screen : PScreen
    ) : Int32

    fun default_screen = XDefaultScreen(
      display : PDisplay
    ) : Int32

    fun define_cursor = XDefineCursor(
      display : PDisplay,
      w : Window,
      cursor : Cursor
    ) : Int32

    fun delete_property = XDeleteProperty(
      display : PDisplay,
      w : Window,
      property : Atom
    ) : Int32

    fun destroy_window = XDestroyWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun destroy_subwindows = XDestroySubwindows(
      display : PDisplay,
      w : Window
    ) : Int32

    fun does_backing_store = XDoesBackingStore(
      screen : PScreen
    ) : Int32

    fun does_save_unders = XDoesSaveUnders(
      screen : PScreen
    ) : Bool

    fun disable_access_control = XDisableAccessControl(
      display : PDisplay
    ) : Int32


    fun display_cells = XDisplayCells(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun display_height = XDisplayHeight(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun display_height_mm = XDisplayHeightMM(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun display_keycodes = XDisplayKeycodes(
      display : PDisplay,
      min_keycodes_return : PInt32,
      max_keycodes_return : PInt32
    ) : Int32

    fun display_planes = XDisplayPlanes(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun display_width = XDisplayWidth(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun display_width_mm = XDisplayWidthMM(
      display : PDisplay,
      screen_number : Int32
    ) : Int32

    fun draw_arc = XDrawArc(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      angle1 : Int32,
      angle2 : Int32
    ) : Int32

    fun draw_arcs = XDrawArcs(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      arcs : PArc,
      narcs : Int32
    ) : Int32

    fun draw_image_string = XDrawImageString(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      string : PChar,
      length : Int32
    ) : Int32

    fun draw_image_string_16 = XDrawImageString16(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      string : PChar2b,
      length : Int32
    ) : Int32

    fun draw_line = XDrawLine(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x1 : Int32,
      y1 : Int32,
      x2 : Int32,
      y2 : Int32
    ) : Int32

    fun draw_lines = XDrawLines(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      points : PPoint,
      npoints : Int32,
      mode : Int32
    ) : Int32

    fun draw_point = XDrawPoint(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32
    ) : Int32

    fun draw_points = XDrawPoints(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      points : PPoint,
      npoints : Int32,
      mode : Int32
    ) : Int32

    fun draw_rectangle = XDrawRectangle(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32
    ) : Int32

    fun draw_rectangles = XDrawRectangles(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      rectangles : PRectangle,
      nrectangles : Int32
    ) : Int32

    fun draw_segments = XDrawSegments(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      segments : PSegment,
      nsegments : Int32
    ) : Int32

    fun draw_string = XDrawString(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      string : PChar,
      length : Int32
    ) : Int32

    fun draw_string_16 = XDrawString16(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      string : PChar2b,
      length : Int32
    ) : Int32

    fun draw_text = XDrawText(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      items : PTextItem,
      nitems : Int32
    ) : Int32

    fun draw_text_16 = XDrawText16(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      items : PTextItem16,
      nitems : Int32
    ) : Int32

    fun enable_access_control = XEnableAccessControl(
      display : PDisplay
    ) : Int32

    fun events_queued = XEventsQueued(
      display : PDisplay,
      mode : Int32
    ) : Int32

    fun fetch_name = XFetchName(
      display : PDisplay,
      w : Window,
      window_name_return : PPChar
    ) : Status

    fun fill_arc = XFillArc(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32,
      angle1 : Int32,
      angle2 : Int32
    ) : Int32

    fun fill_arcs = XFillArcs(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      arcs : PArc,
      narcs : Int32
    ) : Int32

    fun fill_polygon = XFillPolygon(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      points : PPoint,
      npoints :  Int32,
      shape : Int32,
      mode : Int32
    ) : Int32

    fun fill_rectangle = XFillRectangle(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32
    ) : Int32

    fun fill_rectangles = XFillRectangles(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      rectangles : PRectangle,
      nrectangles : Int32
    ) : Int32

    fun flush = XFlush(
      display : PDisplay
    ) : Int32

    fun force_screen_saver = XForceScreenSaver(
      display : PDisplay,
      mode : Int32
    ) : Int32

    fun free = XFree(
      data : PChar
    ) : Int32

    fun free_colormap = XFreeColormap(
      display : PDisplay,
      colormap : Colormap
    ) : Int32

    fun free_colors = XFreeColors(
      display : PDisplay,
      colormap : Colormap,
      pixels : PUInt64,
      npixels : Int32,
      planes : UInt64
    ) : Int32

    fun free_cursor = XFreeCursor(
      display : PDisplay,
      cursor : Cursor
    ) : Int32

    fun free_extension_list = XFreeExtensionList(
      list : PPChar
    ) : Int32

    fun free_font = XFreeFont(
      display : PDisplay,
      font_struct : PFontStruct
    ) : Int32

    fun free_font_info = XFreeFontInfo(
      names : PPChar,
      free_info : PFontStruct,
      actual_count : Int32
    ) : Int32

    fun free_font_names = XFreeFontNames(
      list : PPChar
    ) : Int32

    fun free_font_path = XFreeFontPath(
      list : PPChar
    ) : Int32

    fun free_gc = XFreeGC(
      display : PDisplay,
      gc : GC
    ) : Int32

    fun free_modifiermap = XFreeModifiermap(
      modmap : PModifierKeymap
    ) : Int32

    fun free_pixmap = XFreePixmap(
      display : PDisplay,
      pixmap : Pixmap
    ) : Int32

    fun geometry = XGeometry(
      display : PDisplay,
      screen : Int32,
      position : PChar,
      default_position : PChar,
      bwidth : UInt32,
      fwidth : UInt32,
      fheight : UInt32,
      xadder : Int32,
      yadder : Int32,
      x_return : PInt32,
      y_return : PInt32,
      width_return : PInt32,
      height_return : PInt32
    ) : Int32

    fun get_error_database_text = XGetErrorDatabaseText(
      display : PDisplay,
      name : PChar,
      message : PChar,
      default_string : PChar,
      buffer_return : PChar,
      length : Int32
    ) : Int32

    fun get_error_text = XGetErrorText(
      display : PDisplay,
      code : Int32,
      buffer_return : PChar,
      length : Int32
    ) : Int32

    fun get_font_property = XGetFontProperty(
      font_struct : PFontStruct,
      atom : Atom,
      value_return : PUInt64
    ) : Bool

    fun get_gc_values = XGetGCValues(
      display : PDisplay,
      gc : GC,
      valuemask : UInt64,
      values_return : PGCValues
    ) : Status

    fun get_geometry = XGetGeometry(
      display : PDisplay,
      d : Drawable,
      root_return : PWindow,
      x_return : PInt32,
      y_return : PInt32,
      width_return : PUInt32,
      height_return : PInt32,
      border_width_return : PInt32,
      depth_return : PInt32
    ) : Status

    fun get_icon_name = XGetIconName(
      display : PDisplay,
      w : Window,
      icon_name_return : PPChar
    ) : Status

    fun get_input_focus = XGetInputFocus(
      display : PDisplay,
      focus_return : PWindow,
      revert_to_return : PInt32
    ) : Int32

    fun get_keyboard_control = XGetKeyboardControl(
      display : PDisplay,
      values_return : PKeyboardState
    ) : Int32

    fun get_pointer_control = XGetPointerControl(
      display : PDisplay,
      accel_numerator_return : PInt32,
      accel_denominator_return : PInt32,
      threshold_return : PInt32
    ) : Int32

    fun get_pointer_mapping = XGetPointerMapping(
      display : PDisplay,
      map_return : PChar,
      nmap : Int32
    ) : Int32

    fun get_screen_saver = XGetScreenSaver(
      display : PDisplay,
      timeout_return : PInt32,
      interval_return : PInt32,
      prefer_blanking_return : PInt32,
      allow_exposures_return : PInt32,
    ) : Int32

    fun get_transient_for_hint = XGetTransientForHint(
      display : PDisplay,
      w : Window,
      prop_window_return : PWindow
    ) : Status

    fun get_window_property = XGetWindowProperty(
      display : PDisplay,
      w : Window,
      property : Atom,
      long_offset : Int64,
      long_length : Int64,
      delete : Bool,
      req_type : Atom,
      actual_type_return : PAtom,
      actual_format_return : PInt32,
      nitems_return : PUInt64,
      bytes_after_return : PUInt64,
      prop_return : PPChar
    ) : Int32

    fun get_window_attributes = XGetWindowAttributes(
      display : PDisplay,
      w : Window,
      window_attributes_return : PWindowAttributes
    ) : Status

    fun grab_button = XGrabButton(
      display : PDisplay,
      button : UInt32,
      modifiers : UInt32,
      grab_window : Window,
      owner_events : Bool,
      event_mask : UInt32,
      pointer_mode : Int32,
      keyboard_mode : Int32,
      confine_to : Window,
      cursor : Cursor
    ) : Int32

    fun grab_key = XGrabKey(
      display : PDisplay,
      keycode : Int32,
      modifiers : UInt32,
      grab_window : Window,
      owner_events : Bool,
      pointer_mode : Int32,
      keyboard_mode : Int32
    ) : Int32

    fun grab_keyboard = XGrabKeyboard(
      display : PDisplay,
      grab_window : Window,
      owner_events : Bool,
      pointer_mode : Int32,
      keyboard_mode : Int32,
      time : Time
    ) : Int32

    fun grab_pointer = XGrabPointer(
      display : PDisplay,
      grab_window : Window,
      owner_events : Bool,
      event_mask : UInt32,
      pointer_mode : Int32,
      keyboard_mode : Int32,
      confine_to : Window,
      cursor : Cursor,
      time : Time
    ) : Int32

    fun grab_server = XGrabServer(
      display : PDisplay
    ) : Int32

    fun height_mm_of_screen = XHeightMMOfScreen(
      screen : PScreen
    ) : Int32

    fun height_of_screen = XHeightOfScreen(
      screen : PScreen
    ) : Int32

    fun if_event = XIfEvent(
      display : PDisplay,
      event_return : PEvent,
      predicate : PDisplay, PEvent, Pointer -> Bool,
      arg : Pointer
    );

    fun image_byte_order = XImageByteOrder(
      display : PDisplay
    ) : Int32

    fun install_colormap = XInstallColormap(
      display : PDisplay,
      colormap : Colormap
    ) : Int32

    fun keysym_to_keycode = XKeysymToKeycode(
      display : PDisplay,
      keysym : KeySym
    ) : KeyCode

    fun kill_client = XKillClient(
      display : PDisplay,
      resource : XID
    ) : Int32

    fun lookup_color = XLookupColor(
      display : PDisplay,
      colormap : Colormap,
      color_name : PChar,
      exact_def_return : PColor,
      screen_def_return : PColor
    ) : Status

    fun lower_window = XLowerWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun map_raised = XMapRaised(
      display : PDisplay,
      w : Window
    ) : Int32

    fun map_subwindows = XMapSubwindows(
      display : PDisplay,
      w : Window
    ) : Int32

    fun map_window = XMapWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun mask_event = XMaskEvent(
      display : PDisplay,
      event_mask : Int64,
      event_return : PEvent
    ) : Int32

    fun max_cmaps_of_screen = XMaxCmapsOfScreen(
      screen : PScreen
    ) : Int32

    fun min_cmaps_of_screen = XMinCmapsOfScreen(
      screen : PScreen
    ) : Int32

    fun move_resize_window = XMoveResizeWindow(
      display : PDisplay,
      w : Window,
      x : Int32,
      y : Int32,
      width : UInt32,
      height : UInt32
    ) : Int32

    fun move_window = XMoveWindow(
      display : PDisplay,
      w : Window,
      x : Int32,
      y : Int32
    ) : Int32

    fun next_event = XNextEvent(
      display : PDisplay,
      event_return : PEvent
    ) : Int32

    fun no_op = XNoOp(
      display : PDisplay
    ) : Int32

    fun parse_color = XParseColor(
      display : PDisplay,
      colormap : Colormap,
      spec : PChar,
      exact_def_return : PColor
    ) : Status

    fun parse_geometry = XParseGeometry(
      parsestring : PChar,
      x_return : PInt32,
      y_return : PInt32,
      width_return : PUInt32,
      height_return : PUInt32
    ) : Int32

    fun peek_event = XPeekEvent(
      display : PDisplay,
      event_return : PEvent
    ) : Int32

    fun peek_if_event = XPeekIfEvent(
      display : PDisplay,
      event_return : PEvent,
      predicate : PDisplay, PEvent, Pointer -> Bool,
      arg : Pointer
    ) : Int32

    fun pending = XPending(
      display : PDisplay
    ) : Int32

    fun plane_of_screen = XPlanesOfScreen(
      screen : PScreen
    ) : Int32

    fun protocol_revision = XProtocolRevision(
      display : PDisplay
    ) : Int32

    fun protocol_version = XProtocolVersion(
      display : PDisplay
    ) : Int32

    fun put_back_event = XPutBackEvent(
      display : PDisplay,
      event : PEvent
    ) : Int32

    fun put_image = XPutImage(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      image : PImage,
      src_x : Int32,
      src_y : Int32,
      dest_x : Int32,
      dest_y : Int32,
      width : UInt32,
      height : UInt32
    ) : Int32

    fun q_length = XQLength(
      display : PDisplay
    ) : Int32

    fun query_best_cursor = XQueryBestCursor(
      display : PDisplay,
      d : Drawable,
      width : UInt32,
      height : UInt32,
      width_return : PUInt32,
      height_return : PUInt32
    ) : Status

    fun query_best_size = XQueryBestSize(
      display : PDisplay,
      c_class : Int32,
      which_screen : Drawable,
      width : UInt32,
      height : UInt32,
      width_return : PUInt32,
      height_return : PUInt32
    ) : Status

    fun query_best_stipple = XQueryBestStipple(
      display : PDisplay,
      which_screen : Drawable,
      width : UInt32,
      height : UInt32,
      width_return : PUInt32,
      height_return : PUInt32
    ) : Status

    fun query_best_tile = XQueryBestTile(
      display : PDisplay,
      which_screen : Drawable,
      width : UInt32,
      height : UInt32,
      width_return : PUInt32,
      height_return : PUInt32
    ) : Status

    fun query_color = XQueryColor(
      display : PDisplay,
      colormap : Colormap,
      def_in_out : PColor
    ) : Int32

    fun query_colors = XQueryColors(
      display : PDisplay,
      colormap : Colormap,
      defs_in_out : PColor,
      ncolors : Int32
    ) : Int32

    fun query_extension = XQueryExtension(
      display : PDisplay,
      name : PChar,
      major_opcode_return : PInt32,
      first_event_return : PInt32,
      first_error_return : PInt32
    ) : Bool

    fun query_keymap = XQueryKeymap(
      display : PDisplay,
      keys_return : CChar[32]
    ) : Int32

    fun query_pointer = XQueryPointer(
      display : PDisplay,
      w : Window,
      root_return : PWindow,
      child_return : PWindow,
      root_x_return : PInt32,
      root_y_return : PInt32,
      win_x_return : PInt32,
      win_y_return : PInt32,
      mask_return : PUInt32
    ) : Bool

    fun query_text_extents = XQueryTextExtents(
      display : PDisplay,
      font_ID : XID,
      string : PChar,
      nchars : Int32,
      direction_return : PInt32,
      font_ascent_return : PInt32,
      font_descent_return : PInt32,
      overall_return : PCharStruct
    ) : Int32

    fun query_text_extents_16 = XQueryTextExtents16(
      display : PDisplay,
      font_ID : XID,
      string : PChar2b,
      nchars : Int32,
      direction_return : PInt32,
      font_ascent_return : PInt32,
      font_descent_return : PInt32,
      overall_return : PCharStruct
    ) : Int32

    fun query_tree = XQueryTree(
      display : PDisplay,
      w : Window,
      root_return : PWindow,
      parent_return : PWindow,
      children_return : PWindow*,
      nchildren_return : PUInt32
    ) : Status

    fun raise_window = XRaiseWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun read_bitmap_file = XReadBitmapFile(
      display : PDisplay,
      d : Drawable,
      filename : PChar,
      width_return : PUInt32,
      height_return : PUInt32,
      bitmap_return : PPixmap,
      x_hot_return : PInt32,
      y_hot_return : PInt32
    ) : Int32

    fun read_bitmap_file_data = XReadBitmapFileData(
      filename : PChar,
      width_return : PUInt32,
      height_return : PUInt32,
      data_return : PPChar,
      x_hot_return : PInt32,
      y_hot_return : PInt32
    ) : Int32

    fun rebind_keysym = XRebindKeysym(
      display : PDisplay,
      keysym : KeySym,
      list : PKeySym,
      mod_count : Int32,
      string : PChar,
      bytes_string : Int32
    ) : Int32

    fun recolor_cursor = XRecolorCursor(
      display : PDisplay,
      cursor : Cursor,
      foreground_color : PColor,
      background_color : PColor
    ) : Int32

    fun refresh_keyboard_mapping = XRefreshKeyboardMapping(
      event_map : PMappingEvent
    ) : Int32

    fun remove_from_save_set = XRemoveFromSaveSet(
      display : PDisplay,
      w : Window
    ) : Int32

    fun remove_host = XRemoveHost(
      display : PDisplay,
      host : PHostAddress
    ) : Int32

    fun remove_hosts = XRemoveHosts(
      display : PDisplay,
      hosts : PHostAddress,
      num_hosts : Int32
    ) : Int32

    fun reparent_window = XReparentWindow(
      display : PDisplay,
      w : Window,
      parent : Window,
      x : Int32,
      y : Int32
    ) : Int32

    fun reset_screen_saver = XResetScreenSaver(
      display : PDisplay
    ) : Int32

    fun resize_window = XResizeWindow(
      display : PDisplay,
      w : Window,
      width : UInt32,
      height : UInt32
    ) : Int32

    fun restack_windows = XRestackWindows(
      display : PDisplay,
      windows : PWindow,
      nwindows : Int32
    ) : Int32

    fun rotate_buffers = XRotateBuffers(
      display : PDisplay,
      rotate : Int32
    ) : Int32

    fun rotate_window_properties = XRotateWindowProperties(
      display : PDisplay,
      w : Window,
      properties : PAtom,
      num_prop : Int32,
      npositions : Int32
    ) : Int32

    fun screen_count = XScreenCount(
      display : PDisplay
    ) : Int32

    fun select_input = XSelectInput(
      display : PDisplay,
      w : Window,
      event_mask : Int64
    ) : Int32

    fun send_event = XSendEvent(
      display : PDisplay,
      w : Window,
      propagate : Bool,
      event_mask : Int64,
      event_send : PEvent
    ) : Status

    fun set_access_control = XSetAccessControl(
      display : PDisplay,
      mode : Int32
    ) : Int32

    fun set_arc_mode = XSetArcMode(
      display : PDisplay,
      gc : GC,
      arc_mode : Int32
    ) : Int32

    fun set_background = XSetBackground(
      display : PDisplay,
      gc : GC,
      background : UInt64
    ) : Int32

    fun set_clip_mask = XSetClipMask(
      display : PDisplay,
      gc : GC,
      pixmap : Pixmap
    ) : Int32

    fun set_clip_origin = XSetClipOrigin(
      display : PDisplay,
      gc : GC,
      clip_x_origin : Int32,
      clip_y_origin : Int32
    ) : Int32

    fun set_clip_rectangles = XSetClipRectangles(
      display : PDisplay,
      gc : GC,
      clip_x_origin : Int32,
      clip_y_origin : Int32,
      rectangles : PRectangle,
      n : Int32,
      ordering : Int32
    ) : Int32

    fun set_close_down_mode = XSetCloseDownMode(
      display : PDisplay,
      close_mode : Int32
    ) : Int32

    fun set_command = XSetCommand(
      display : PDisplay,
      w : Window,
      argv : PPChar,
      argc : Int32
    ) : Int32

    fun set_dashes = XSetDashes(
      display : PDisplay,
      gc : GC,
      dash_offset : Int32,
      dash_list : PChar,
      n : Int32
    ) : Int32

    fun set_fill_rule = XSetFillRule(
      display : PDisplay,
      gc : GC,
      fill_rule : Int32
    ) : Int32

    fun set_fill_style = XSetFillStyle(
      display : PDisplay,
      gc : GC,
      fill_style : Int32
    ) : Int32

    fun set_font = XSetFont(
      display : PDisplay,
      gc : GC,
      font : Font
    ) : Int32

    fun set_font_path = XSetFontPath(
      display : PDisplay,
      directories : PPChar,
      ndirs : Int32
    ) : Int32

    fun set_foreground = XSetForeground(
      display : PDisplay,
      gc : GC,
      foreground : UInt64
    ) : Int32

    fun set_function = XSetFunction(
      display : PDisplay,
      gc : GC,
      function : Int32
    ) : Int32

    fun set_graphics_exposures = XSetGraphicsExposures(
      display : PDisplay,
      gc : GC,
      graphics_exposures : Bool
    ) : Int32

    fun set_icon_name = XSetIconName(
      display : PDisplay,
      w : Window,
      icon_name : PChar
    ) : Int32

    fun set_input_focus = XSetInputFocus(
      display : PDisplay,
      focus : Window,
      revert_to : Int32,
      time : Time
    ) : Int32

    fun set_line_attributes = XSetLineAttributes(
      display : PDisplay,
      gc : GC,
      line_width : UInt32,
      line_style : Int32,
      cap_style : Int32,
      join_style : Int32
    ) : Int32

    fun set_modifier_mapping = XSetModifierMapping(
      display : PDisplay,
      modmap : PModifierKeymap
    ) : Int32

    fun set_plane_mask = XSetPlaneMask(
      display : PDisplay,
      gc : GC,
      plane_mask : UInt64
    ) : Int32

    fun set_pointer_mapping = XSetPointerMapping(
      display : PDisplay,
      map : PChar,
      nmap : Int32
    ) : Int32

    fun set_screen_saver = XSetScreenSaver(
      display : PDisplay,
      timeout : Int32,
      interval : Int32,
      prefer_blanking : Int32,
      allow_exposures : Int32
    ) : Int32

    fun set_selection_owner = XSetSelectionOwner(
      display : PDisplay,
      selection : Atom,
      owner : Window,
      time : Time
    ) : Int32

    fun set_state = XSetState(
      display : PDisplay,
      gc : GC,
      foreground : UInt64,
      background : UInt64,
      function : Int32,
      plane_mask : UInt64
    ) : Int32

    fun set_stipple = XSetStipple(
      display : PDisplay,
      gc : GC,
      stipple : Pixmap
    ) : Int32

    fun set_subwindow_mode = XSetSubwindowMode(
      display : PDisplay,
      gc : GC,
      subwindow_mode : Int32
    ) : Int32

    fun set_ts_origin = XSetTSOrigin(
      display : PDisplay,
      gc : GC,
      ts_x_origin : Int32,
      ts_y_origin : Int32
    ) : Int32

    fun set_tile = XSetTile(
      display : PDisplay,
      gc : GC,
      tile : Pixmap
    ) : Int32

    fun set_window_background = XSetWindowBackground(
      display : PDisplay,
      w : Window,
      background_pixel : UInt64
    ) : Int32

    fun set_window_background_pixmap = XSetWindowBackgroundPixmap(
      display : PDisplay,
      w : Window,
      background_pixmap : Pixmap
    ) : Int32

    fun set_window_border = XSetWindowBorder(
      display : PDisplay,
      w : Window,
      border_pixel : UInt64
    ) : Int32

    fun set_window_border_pixmap = XSetWindowBorderPixmap(
      display : PDisplay,
      w : Window,
      border_pixmap : Pixmap
    ) : Int32

    fun set_window_border_width = XSetWindowBorderWidth(
      display : PDisplay,
      w : Window,
      width : UInt32
    ) : Int32

    fun set_window_colormap = XSetWindowColormap(
      display : PDisplay,
      w : Window,
      colormap : Colormap
    ) : Int32

    fun store_buffer = XStoreBuffer(
      display : PDisplay,
      bytes  : PChar,
      nbytes : Int32,
      buffer : Int32
    ) : Int32

    fun store_bytes = XStoreBytes(
      display : PDisplay,
      bytes : PChar,
      nbytes : Int32
    ) : Int32

    fun store_color = XStoreColor(
      display : PDisplay,
      colormap : Colormap,
      color : PColor
    ) : Int32

    fun store_colors = XStoreColors(
      display : PDisplay,
      colormap : Colormap,
      color : PColor,
      ncolors : Int32
    ) : Int32

    fun store_name = XStoreName(
      display : PDisplay,
      w : Window,
      window_name : PChar
    ) : Int32

    fun store_named_color = XStoreNamedColor(
      display : PDisplay,
      colormap : Colormap,
      color : PColor,
      pixel : UInt64,
      flags : Int32
    ) : Int32

    fun sync = XSync(
      display : PDisplay,
      discard : Bool
    ) : Int32

    fun text_extents = XTextExtents(
      font_struct : PFontStruct,
      string : PChar,
      nchars : Int32,
      direction_return : PInt32,
      font_ascent_return : PInt32,
      font_descent_return : PInt32,
      overall_return : PCharStruct
    ) : Int32

    fun text_extents_16 = XTextExtents16(
      font_struct : PFontStruct,
      string : PChar2b,
      nchars : Int32,
      direction_return : PInt32,
      font_ascent_return : PInt32,
      font_descent_return : PInt32,
      overall_return : PCharStruct
    ) : Int32

    fun text_width = XTextWidth(
      font_struct : PFontStruct,
      string : PChar,
      count : Int32
    ) : Int32

    fun text_width_16 = XTextWidth16(
      font_struct : PFontStruct,
      string : PChar2b,
      count : Int32
    ) : Int32

    fun translate_coordinates = XTranslateCoordinates(
      display : PDisplay,
      src_w : Window,
      dest_w : Window,
      src_x : Int32,
      src_y : Int32,
      dest_x_return : PInt32,
      dest_y_return : PInt32,
      child_return : PWindow
    ) : Bool

    fun undefine_cursor = XUndefineCursor(
      display : PDisplay,
      w : Window
    ) : Int32

    fun ungrab_button = XUngrabButton(
      display : PDisplay,
      button : UInt32,
      modifiers : UInt32,
      grab_window : Window
    ) : Int32

    fun ungrab_key = XUngrabKey(
      display : PDisplay,
      keycode : Int32,
      modifiers : UInt32,
      grab_window : Window
    ) : Int32

    fun ungrab_keyboard = XUngrabKeyboard(
      display : PDisplay,
      time : Time
    ) : Int32

    fun ungrab_pointer = XUngrabPointer(
      display : PDisplay,
      time : Time
    ) : Int32

    fun ungrab_server = XUngrabServer(
      display : PDisplay
    ) : Int32

    fun uninstall_colormap = XUninstallColormap(
      display : PDisplay,
      colormap : Colormap
    ) : Int32

    fun unload_font = XUnloadFont(
      display : PDisplay,
      font : Font
    ) : Int32

    fun unmap_subwindows = XUnmapSubwindows(
      display : PDisplay,
      w : Window
    ) : Int32

    fun unmap_window = XUnmapWindow(
      display : PDisplay,
      w : Window
    ) : Int32

    fun vendor_release = XVendorRelease(
      display : PDisplay
    ) : Int32

    fun warp_pointer = XWarpPointer(
      display : PDisplay,
      src_w : Window,
      dest_w : Window,
      src_x : Int32,
      src_y : Int32,
      src_width : UInt32,
      src_height : UInt32,
      dest_x : Int32,
      dest_y : Int32
    ) : Int32

    fun width_mm_of_screen = XWidthMMOfScreen(
      screen : PScreen
    ) : Int32

    fun width_of_screen = XWidthOfScreen(
      screen : PScreen
    ) : Int32

    fun window_event = XWindowEvent(
      display : PDisplay,
      w : Window,
      event_mask : Int64,
      event_return : PEvent
    ) : Int32

    fun write_bitmap_file = XWriteBitmapFile(
      display : PDisplay,
      filename : PChar,
      bitmap : Pixmap,
      width : UInt32,
      height : UInt32,
      x_hot : Int32,
      y_hot : Int32
    ) : Int32

    fun supports_locale = XSupportsLocale() : Bool

    fun set_locale_modifiers = XSetLocaleModifiers(
      modifier_list : PChar
    ) : PChar

    fun open_om = XOpenOM(
      display : PDisplay,
      rdb : PrmHashBucketRec,
      res_name : PChar,
      res_class : PChar
    ) : XOM

    fun close_om = XCloseOM(
      om : XOM
    ) : Status

    fun set_om_values = XSetOMValues(
      om : XOM,
      ...
    ) : PChar

    fun get_om_values = XGetOMValues(
      om : XOM,
      ...
    ) : PChar;

    fun display_of_om = XDisplayOfOM(
      om : XOM
    ) : PDisplay

    fun locale_of_om = XLocaleOfOM(
      om : XOM
    ) : PChar

    fun create_oc = XCreateOC(
      om : XOM,
      ...
    ) : XOC

    fun destroy_oc = XDestroyOC(
      oc : XOC
    ) : NoReturn

    fun om_of_oc = XOMOfOC(
      oc : XOC
    ) : XOM

    fun set_oc_values = XSetOCValues(
      oc : XOC,
      ...
    ) : PChar;

    fun get_oc_values = XGetOCValues(
      oc : XOC,
      ...
    ) : PChar

    fun create_font_set = XCreateFontSet(
      display : PDisplay,
      base_font_name_list : PChar,
      missing_charset_list_return : PPChar*,
      missing_charset_count_return : PInt32,
      def_string_return : PPChar
    ) : FontSet

    fun free_font_set = XFreeFontSet(
      display : PDisplay,
      font_set : FontSet
    ) : NoReturn

    fun fonts_of_font_set = XFontsOfFontSet(
      font_set : FontSet,
      font_struct_list : PFontStruct**,
      font_name_list : PPChar*
    ) : Int32

    fun base_font_name_list_of_font_set = XBaseFontNameListOfFontSet(
      font_set : FontSet
    ) : PChar

    fun locale_of_font_set = XLocaleOfFontSet(
      font_set : FontSet
    ) : PChar

    fun context_dependent_drawing = XContextDependentDrawing(
      font_set : FontSet
    ) : Bool

    fun directional_dependent_drawing = XDirectionalDependentDrawing(
      font_set : FontSet
    ) : Bool

    fun contextual_drawing = XContextualDrawing(
      font_set : FontSet
    ) : Bool

    fun extents_of_font_set = XExtentsOfFontSet(
      font_set : FontSet
    ) : PFontSetExtents

    fun mb_text_escapement = XmbTextEscapement(
      font_set: FontSet,
      text : PChar,
      bytes_text : Int32
    ) : Int32

    fun wc_text_escapement = XwcTextEscapement(
      font_set : FontSet,
      text : PWCharT,
      num_wchars : Int32
    ) : Int32

    fun utf8_text_escapement = utf8TextEscapement(
      font_set : FontSet,
      text : PChar,
      bytes_text : Int32
    ) : Int32

    fun mb_text_extents = XmbTextExtents(
      font_set : FontSet,
      text : PChar,
      bytes_text : Int32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Int32

    fun wc_text_extents = XwcTextExtents(
      font_set : FontSet,
      text : PWCharT,
      num_wchars : Int32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Int32

    fun utf8_text_extents = Xutf8TextExtents(
      font_set : FontSet,
      text : PChar,
      bytes_text : Int32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Int32

    fun mb_text_per_char_extents = XmbTextPerCharExtents(
      font_set : FontSet,
      text : PChar,
      bytes_text : Int32,
      ink_extents_buffer : PRectangle,
      logical_extents_buffer : PRectangle,
      buffer_size : Int32,
      num_chars : PInt32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Status

    fun wc_text_per_char_extents = XwcTextPerCharExtents(
      font_set : FontSet,
      text : PWCharT,
      num_wchars : Int32,
      ink_extents_buffer : PRectangle,
      logical_extents_buffer : PRectangle,
      buffer_size : Int32,
      num_chars : PInt32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Status

    fun utf8_text_per_char_extents = Xutf8TextPerCharExtents(
      font_set : FontSet,
      text : PChar,
      bytes_text : Int32,
      ink_extents_buffer : PRectangle,
      logical_extents_buffer : PRectangle,
      buffer_size : Int32,
      num_chars : PInt32,
      overall_ink_return : PRectangle,
      overall_logical_return : PRectangle
    ) : Status

    fun mb_draw_text = XmbDrawText(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      text_items : PmbTextItem,
      nitems : Int32
    ) : NoReturn

    fun wc_draw_text = XwcDrawText(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      text_items : PwcTextItem,
      nitems : Int32
    ) : NoReturn

    fun utf8_draw_text = Xutf8DrawText(
      display : PDisplay,
      d : Drawable,
      gc : GC,
      x : Int32,
      y : Int32,
      text_items : PmbTextItem,
      nitems : Int32
    ) : NoReturn

    fun mb_draw_string = XmbDrawString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PChar,
      bytes_text : Int32
    ) : NoReturn

    fun wc_draw_string = XwcDrawString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PWCharT,
      num_wchars : Int32
    ) : NoReturn

    fun utf8_draw_string = Xutf8DrawString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PChar,
      bytes_text : Int32
    ) : NoReturn

    fun mb_draw_image_string = XmbDrawImageString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PChar,
      bytes_text : Int32
    ) : NoReturn

    fun wc_draw_image_string = XwcDrawImageString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PWCharT,
      num_wchars : Int32
    ) : NoReturn

    fun utf8_draw_image_string = Xutf8DrawImageString(
      display : PDisplay,
      d : Drawable,
      font_set : FontSet,
      gc : GC,
      x : Int32,
      y : Int32,
      text : PChar,
      bytes_text : Int32
    ) : NoReturn

    fun open_im = XOpenIM(
      dpy : PDisplay,
      rdb : PrmHashBucketRec,
      res_name : PChar,
      res_class : PChar
    ) : XIM

    fun close_im = XCloseIM(
      im : XIM
    ) : Status

    fun get_im_values = XGetIMValues(
      im : XIM,
      ...
    ) : PChar

    fun set_im_values = XSetIMValues(
      im : XIM,
      ...
    ) : PChar

    fun display_of_im = XDisplayOfIM(
      im : XIM
    ) : PDisplay

    fun locale_of_im = XLocaleOfIM(
      im : XIM
    ) : PChar

    fun create_ic = XCreateIC(
      im : XIM,
      ...
    ) : XIC

    fun destroy_ic = XDestroyIC(
      ic : XIC
    ) : NoReturn

    fun set_ic_focus = XSetICFocus(
      ic : XIC
    ) : NoReturn

    fun unset_ic_focus = XUnsetICFocus(
      ic : XIC
    ) : NoReturn

    fun wc_reset_ic = XwcResetIC(
      ic : XIC
    ) : PWCharT

    fun mb_reset_ic = XmbResetIC(
      ic : XIC
    ) : PChar

    fun utf8_reset_ic = Xutf8ResetIC(
      ic : XIC
    ) : PChar

    fun set_ic_values = XSetICValues(
      ic : XIC,
      ...
    ) : PChar

    fun get_ic_values = XGetICValues(
      ic : XIC,
      ...
    ) : PChar

    fun im_of_ic = XIMOfIC(
      ic : XIC
    ) : XIM

    fun filter_event = XFilterEvent(
      event : PEvent,
      window : PWindow
    ) : Bool

    fun mb_lookup_string = XmbLookupString(
      ic : XIC,
      event : PKeyPressedEvent,
      buffer_return : PChar,
      bytes_buffer : Int32,
      keysym_return : PKeySym,
      status_return : PStatus
    ) : Int32

    fun wc_lookup_string = XwcLookupString(
      ic : XIC,
      event : PKeyPressedEvent,
      buffer_return : PWCharT,
      wchars_buffer : Int32,
      keysym_return : PKeySym,
      status_return : PStatus
    ) : Int32

    fun utf8_lookup_string = Xutf8LookupString(
      ic : XIC,
      event : PKeyPressedEvent,
      buffer_return : PChar,
      bytes_buffer : Int32,
      keysym_return : PKeySym,
      status_return : PStatus
    ) : Int32

    fun va_create_nested_list = XVaCreateNestedList(
      unused : Int32,
      ...
    ) : VaNestedList

    # internal connections for IMs

    fun register_im_instantiate_callback = XRegisterIMInstantiateCallback(
      dpy : PDisplay,
      rdb : PrmHashBucketRec,
      res_name : PChar,
      res_class : PChar,
      callback : IDProc,
      client_data : Pointer
    ) : Bool

    fun unregister_im_instantiate_callback = XUnregisterIMInstantiateCallback(
      dpy : PDisplay,
      rdb : PrmHashBucketRec,
      res_name : PChar,
      res_class : PChar,
      callback : IDProc,
      client_data : Pointer
    ) : Bool

    alias ConnectionWatchProc = PDisplay, Pointer, Int32, Bool, Pointer* -> NoReturn

    fun internal_connection_numbers = XInternalConnectionNumbers(
      dpy : PDisplay,
      fd_return : PInt32*,
      count_return : PInt32
    ) : Status

    fun process_internal_connection = XProcessInternalConnection(
      dpy : PDisplay,
      fd : Int32
    ) : NoReturn

    fun add_connectioin_watch = XAddConnectionWatch(
      dpy : PDisplay,
      callback : ConnectionWatchProc,
      client_data : Pointer
    ) : Status

    fun remove_connection_watch = XRemoveConnectionWatch(
      dpy : PDisplay,
      callback : ConnectionWatchProc,
      client_data : Pointer
    ) : NoReturn

    fun set_authorization = XSetAuthorization(
      name : PChar,
      namelen : Int32,
      data : PChar,
      datalen : Int32
    ) : NoReturn

    fun mbtowc = _Xmbtowc(
      wstr : PWCharT,
      str : PChar,
      len : Int32
    ) : Int32

    fun wctomb = _Xwctomb(
      str : PChar,
      wc : PWCharT
    ) : Int32

    fun get_event_data = XGetEventData(
      dpy : PDisplay,
      cookie : PGenericEventCookie
    ) : Bool

    fun free_event_data = XFreeEventData(
      dpy : PDisplay,
      cookie : PGenericEventCookie
    ) : NoReturn

  end # lib Xlib

  X._Xdebug = 0

  def self.connection_number(dpy)
    dpy.value.fd
  end

  def self.root_window(dpy, scr)
    self.screen_of_display(dpy, scr).root
  end

  def self.default_screen(dpy)
    dpy.value.default_screen
  end

  def self.default_root_window(dpy)
    self.screen_of_display(dpy, self.default_screen(dpy)).root
  end

  def self.default_visual(dpy, scr)
    self.screen_of_display(dpy, scr).root_visual
  end

  def self.default_gc(dpy, scr)
    self.screen_of_display(dpy, scr).default_gc
  end

  def self.black_pixel(dpy, scr)
    self.screen_of_display(dpy, scr).black_pixel
  end

  def self.white_pixel(dpy, scr)
    self.screen_of_display(dpy, scr).white_pixel
  end

  def self.all_planes
    ~0_u64
  end

  def self.q_length(dpy)
    dpy.value.qlen
  end

  def self.display_width(dpy, scr)
    self.screen_of_display(dpy, scr).width
  end

  def self.display_height(dpy, scr)
    self.screen_of_display(dpy,scr).height
  end

  def self.display_width_mm(dpy, scr)
    self.screen_of_display(dpy,scr).mwidth
  end

  def self.display_height_mm(dpy, scr)
    self.screen_of_display(dpy, scr).mheight
  end

  def self.display_planes(dpy, scr)
    self.screen_of_display(dpy, scr).root_depth
  end

  def self.display_cells(dpy, scr)
    self.default_visual(dpy, scr).value.map_entries
  end

  def self.screen_count(dpy)
    dpy.value.nscreens
  end

  def self.server_vendor(dpy)
    dpy.value.vendor
  end

  def self.protocol_version(dpy)
    dpy.value.proto_major_version
  end

  def self.protocol_revision(dpy)
    dpy.value.proto_minor_version
  end

  def self.vendor_release(dpy)
    dpy.value.release
  end

  def self.display_string(dpy)
    dpy.value.display_name
  end

  def self.default_depth(dpy, scr)
    self.screen_of_display(dpy, scr).root_depth
  end

  def self.default_colormap(dpy, scr)
    self.screen_of_display(dpy, scr).cmap
  end

  def self.bitmap_unit(dpy)
    dpy.value.bitmap_unit
  end

  def self.bitmap_bit_order(dpy)
    dpy.value.bitmap_bit_order
  end

  def self.bitmap_pad(dpy)
    dpy.value.bitmap_pad
  end

  def self.image_byte_order(dpy)
    dpy.value.byte_order
  end

  def self.next_request(dpy)
    dpy.value.request + 1
  end

  def self.last_known_request_processed(dpy)
    dpy.value.last_request_read
  end

  # macros for screen oriented applications (toolkit)
  def self.screen_of_display(dpy, scr)
    dpy.value.screens[scr]
  end

  def self.default_screen_of_display(dpy)
    self.screen_of_display(dpy, default_screen(dpy))
  end

  def self.display_of_screen(s)
    s.value.display
  end

  def self.root_window_of_screen(s)
    s.value.root
  end

  def self.black_pixel_of_screen(s)
    s.value.black_pixel
  end

  def self.white_pixel_of_screen(s)
    s.value.white_pixel
  end

  def self.default_colormap_of_screen(s)
    s.value.cmap
  end

  def self.default_depth_of_screen(s)
    s.value.root_depth
  end

  def self.default_gc_of_screen(s)
    s.value.default_gc
  end

  def self.default_visual_of_screen(s)
    s.value.root_visual
  end

  def self.width_of_screen(s)
    s.value.width
  end

  def self.height_of_screen(s)
    s.value.height
  end

  def self.width_mm_of_screen(s)
    s.value.mwidth
  end

  def self.height_mm_of_screen(s)
    s.value.mheight
  end

  def self.planes_of_screen(s)
    s.value.root_depth
  end

  def self.cells_of_screen(s)
    self.default_visual_of_screen(s).value.map_entries
  end

  def self.min_cmaps_of_screen(s)
    s.min_maps
  end

  def self.max_cmaps_of_screen(s)
    s.max_maps
  end

  def self.does_save_unders(s)
    s.save_unders
  end

  def self.does_backing_store(s)
    s.backing_store
  end

  def self.event_mask_of_screen(s)
    s.root_input_mask
  end
end # module X11

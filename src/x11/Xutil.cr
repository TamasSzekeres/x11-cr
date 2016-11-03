module X11
  # Bitmask returned by XParseGeometry().  Each bit tells if the corresponding
  # value (x, y, width, height) was found in the parsed string.
  NoValue = 0x0000
  XValue = 0x0001
  YValue = 0x0002
  WidthValue = 0x0004
  HeightValue = 0x0008
  AllValues = 0x000F
  XNegative = 0x0010
  YNegative = 0x0020

  # new version containing base_width, base_height, and win_gravity fields;
  # used with WM_NORMAL_HINTS.
  alias PSizeHints = SizeHints*
  struct SizeHints
    flags : Int64 # marks which fields in this structure are defined
    x, y : Int32 # obsolete for new window mgrs, but clients
    width, height : Int32 # should set so old wm's don't mess up
    min_width, min_height : Int32
    max_width, max_height : Int32
    width_inc, height_inc : Int32
    min_aspect, max_aspect : SizeHint_Aspect
    base_width, base_height : Int32 # added by ICCCM version 1
    win_gravity : Int32 # added by ICCCM version 1
  end

  struct SizeHint_Aspect
    x : Int32 # numerator
    y : Int32 # denominator
  end

  # The next block of definitions are for window manager properties that
  # clients and applications use for communication.

  # flags argument in size hints
  USPosition  = (1_i64 << 0) # user specified x, y
  USSize      = (1_i64 << 1) # user specified width, height

  PPosition   = (1_i64 << 2) # program specified position
  PSize       = (1_i64 << 3) # program specified size
  PMinSize    = (1_i64 << 4) # program specified minimum size
  PMaxSize    = (1_i64 << 5) # program specified maximum size
  PResizeInc  = (1_i64 << 6) # program specified resize increments
  PAspect     = (1_i64 << 7) # program specified min and max aspect ratios
  PBaseSize   = (1_i64 << 8) # program specified base for incrementing
  PWinGravity = (1_i64 << 9) # program specified window gravity

  # obsolete
  #PAllHints = PPosition | PSize | PMinSize | PMaxSize | PResizeInc | PAspect

  alias PWMHints = WMHints*
  struct WMHints
    flags : Int64 # marks which fields in this structure are defined
    input : Bool # does this application rely on the window manager to get keyboard input?
    initial_state : Int32 # see below
    icon_pixmap : Pixmap # pixmap to be used as icon
    icon_window : Window # window to be used as icon
    icon_x, icon_y : Int32 # initial position of icon
    icon_mask : Pixmap # icon mask bitmap
    window_group : XID # id of related window group
    # this structure may be extended in the future
  end

  # definition for flags of XWMHints

  InputHint        = (1_i64 << 0)
  StateHint        = (1_i64 << 1)
  IconPixmapHint   = (1_i64 << 2)
  IconWindowHint   = (1_i64 << 3)
  IconPositionHint = (1_i64 << 4)
  IconMaskHint     = (1_i64 << 5)
  WindowGroupHint  = (1_i64 << 6)
  AllHints         = InputHint | StateHint | IconPixmapHint | IconWindowHint | IconPositionHint | IconMaskHint | WindowGroupHint
  XUrgencyHint     = (1_i64 << 8)

  # definitions for initial window state
  WithdrawnState = 0  # for windows that are not mapped
  NormalState    = 1 # most applications want to start this way
  IconicState    = 3 # application wants to start as an icon

  # Obsolete states no longer defined by ICCCM
  DontCareState = 0 # don't know or care
  ZoomState     = 2 # application wants to start zoomed
  InactiveState = 4 # application believes it is seldom used;
  # some wm's may put it on inactive menu

  # new structure for manipulating TEXT properties; used with WM_NAME,
  # WM_ICON_NAME, WM_CLIENT_MACHINE, and WM_COMMAND.
  alias PTextProperty = TextProperty*
  struct TextProperty
    value : PUInt8 # same as Property routines
    encoding : Atom # prop type
    format : Int32 # prop data format: 8, 16, or 32
    nitems : UInt64 # number of data items in value
  end

  XNoMemory           = -1
  XLocaleNotSupported = -2
  XConverterNotFound  = -3

  alias PICCEncodingStyle = ICCEncodingStyle*
  enum ICCEncodingStyle {
    StringStyle # STRING
    CompoundTextStyle # COMPOUND_TEXT
    TextStyle # text in owner's encoding (current locale)
    StdICCTextStyle # STRING, else COMPOUND_TEXT
    # The following is an XFree86 extension, introduced in November 2000
    UTF8StringStyle # UTF8_STRING
  end

  alias PIconSize = IconSize*
  struct IconSize
    min_width, min_height : Int32
    max_width, max_height : Int32
    width_inc, height_inc : Int32
  end

  alias PClassHint = ClassHint*
  struct ClassHint
    res_name : PChar
    res_class : PChar
  end

  ifdef XUTIL_DEFINE_FUNCTIONS
    fun destroy_image = XDestroyImage(
      ximage : PImage
    ) : Int32

    fun get_pixel = XGetPixel(
      ximage : PImage,
      x : Int32,
      y : Int32
    ) : UInt64

    fun put_pixel = XPutPixel(
      ximage : PImage,
      x : Int32,
      y : Int32,
      pixel : UInt64
    ) : Int32

    fun sub_image = XSubImage(
        ximage : PImage,
        x : Int32,
        y : Int32,
        width : UInt32,
        height : UInt32
    ) : PImage

    fun add_pixel = XAddPixel(
      ximage : PImage,
      value : Int64
    ) : Int32
  else
    # These macros are used to give some sugar to the image routines so that
    # naive people are more comfortable with them.
    def destroy_image(ximage)
      ximage.value.f.destroy_image(ximage)
    end

    def get_pixel(ximage, x, y)
      ximage.value.f.get_pixel(ximage, x, y)
    end

    def put_pixel(ximage, x, y, pixel)
      ximage.value.f.put_pixel(ximage, x, y, pixel)
    end

    def sub_image(ximage, x, y, width, height)
      ximage.value.f.sub_image(ximage, x, y, width, height)
    end

    def add_pixel(ximage, value)
      ximage.value.f.add_pixel(ximage, value)
    end
  end

/*
 * Compose sequence status structure, used in calling XLookupString.
 */
typedef struct _XComposeStatus {
    XPointer compose_ptr;	/* state table pointer */
    int chars_matched;		/* match state */
} XComposeStatus;

/*
 * Keysym macros, used on Keysyms to test for classes of symbols
 */
#define IsKeypadKey(keysym) \
  (((KeySym)(keysym) >= XK_KP_Space) && ((KeySym)(keysym) <= XK_KP_Equal))

#define IsPrivateKeypadKey(keysym) \
  (((KeySym)(keysym) >= 0x11000000) && ((KeySym)(keysym) <= 0x1100FFFF))

#define IsCursorKey(keysym) \
  (((KeySym)(keysym) >= XK_Home)     && ((KeySym)(keysym) <  XK_Select))

#define IsPFKey(keysym) \
  (((KeySym)(keysym) >= XK_KP_F1)     && ((KeySym)(keysym) <= XK_KP_F4))

#define IsFunctionKey(keysym) \
  (((KeySym)(keysym) >= XK_F1)       && ((KeySym)(keysym) <= XK_F35))

#define IsMiscFunctionKey(keysym) \
  (((KeySym)(keysym) >= XK_Select)   && ((KeySym)(keysym) <= XK_Break))

#ifdef XK_XKB_KEYS
#define IsModifierKey(keysym) \
  ((((KeySym)(keysym) >= XK_Shift_L) && ((KeySym)(keysym) <= XK_Hyper_R)) \
   || (((KeySym)(keysym) >= XK_ISO_Lock) && \
       ((KeySym)(keysym) <= XK_ISO_Level5_Lock)) \
   || ((KeySym)(keysym) == XK_Mode_switch) \
   || ((KeySym)(keysym) == XK_Num_Lock))
#else
#define IsModifierKey(keysym) \
  ((((KeySym)(keysym) >= XK_Shift_L) && ((KeySym)(keysym) <= XK_Hyper_R)) \
   || ((KeySym)(keysym) == XK_Mode_switch) \
   || ((KeySym)(keysym) == XK_Num_Lock))
#endif
/*
 * opaque reference to Region data type
 */
typedef struct _XRegion *Region;

  # Return values from RectInRegion()
  RectangleOut  = 0
  RectangleIn   = 1
  RectanglePart = 2

  # Information used by the visual utility routines to find desired visual
  # type from the many visuals a display may support.
  alias PVisualInfo = VisualInfo*
  struct VisualInfo
    visual : PVisual
    visualid : VisualID
    screen : Int32
    depth : Int32
    c_class : Int32
    red_mask : UInt64
    green_mask : UIn64
    blue_mask : UInt64
    colormap_size : In32
    bits_per_rgb : Int32
  end

  VisualNoMask           = 0x0
  VisualIDMask           = 0x1
  VisualScreenMask       = 0x2
  VisualDepthMask        = 0x4
  VisualClassMask        = 0x8
  VisualRedMaskMask      = 0x10
  VisualGreenMaskMask    = 0x20
  VisualBlueMaskMask     = 0x40
  VisualColormapSizeMask = 0x80
  VisualBitsPerRGBMask   = 0x100
  VisualAllMask          = 0x1FF


  # This defines a window manager property that clients may use to
  # share standard color maps of type RGB_COLOR_MAP:
  alias PStandardColormap = StandardColormap*
  struct StandardColormap
    colormap : Colormap
	  red_max : UInt64
	  red_mult : UInt64
	  green_max : UInt64
	  green_mult : UInt64
	  blue_max : UInt64
	  blue_mult : UInt64
	  base_pixel : UInt64
    visualid : VisualID # added by ICCCM version 1
    killid : XID # added by ICCCM version 1
  end

  ReleaseByFreeingColormap = 1_i64 # for killid field above

  # return codes for XReadBitmapFile and XWriteBitmapFile
  BitmapSuccess     = 0
  BitmapOpenFailed  = 1
  BitmapFileInvalid = 2
  BitmapNoMemory    = 3

  #****************************************************************
  #
  # Context Management
  #
  #****************************************************************

  # Associative lookup table return codes

  CSUCCESS = 0 # No error.
  CNOMEM   = 1 # Out of memory
  CNOENT   = 2 # No entry in table

  alias Context = Int32

#define XUniqueContext()       ((XContext) XrmUniqueQuark())
#define XStringToContext(string)   ((XContext) XrmStringToQuark(string))

  # The following declarations are alphabetized.

  fun alloc_class_hint = XAllocClassHint (
  ) : PClassHint

  fun alloc_icon_size = XAllocIconSize (
  ) : PIconSize

  fun alloc_size_hints = XAllocSizeHints (
  ) : PSizeHints

  fun alloc_standard_colormap = XAllocStandardColormap (
  ) : PStandardColormap

  fun alloc_wm_hints = XAllocWMHints (
  ): PWMHints

  fun clip_box = XClipBox(
    r : Region,
    rect_return : PRectangle
  ) : Int32

  fun create_region = XCreateRegion(
  ) : Region

  fun default_string = XDefaultString() : PChar

  fun delete_context = XDeleteContext(
    display : PDisplay,
    rid : XID,
    context : Context
  ) : Int32

  fun destroy_region = XDestroyRegion(
    r : Region
  ) : Int32

  fun empty_region = XEmptyRegion(
    r : Region
  ) : Int32

  fun equal_region = XEqualRegion(
    r1 : Region,
    r2 : Region
  ) : Int32

  fun find_context = XFindContext(
    display : PDisplay,
    rid : XID,
    context : Context,
    data_return : Pointer*
  ) : Int32

  fun get_class_hint = XGetClassHint(
    display : PDisplay,
    w : Window,
    class_hints_return : PClassHint
  ) : Status

  fun get_icon_sizws = XGetIconSizes(
    display : PDisplay,
    w : Window,
    size_list_return : PIconSize*,
    count_return : PInt32
  ) : Status

  fun get_normal_hints = XGetNormalHints(
    display : PDisplay,
    w : Window,
    hints_return : PSizeHints
  ) : Status

  fun get_rgb_colormaps = XGetRGBColormaps(
    display : PDisplay,
    w : Window,
    stdcmap_return : PStandardColormap*,
    count_return : PInt32,
    property : Atom
  ) : Status

  fun get_size_hints = XGetSizeHints(
    display : PDisplay,
    w : Window,
    hints_return : PSizeHints,
    property : Atom
  ) : Status

  fun get_standard_colormap = XGetStandardColormap(
    display : PDisplay,
    w : Window,
    colormap_return : PStandardColormap,
    property : Atom
  ) : Status

  fun get_text_property = XGetTextProperty(
    display : PDisplay,
    window : Window,
    text_prop_return : PTextProperty,
    property : Atom
  ) : Status

  fun get_visual_info = XGetVisualInfo(
    display : PDisplay,
    vinfo_mask : Int64,
    vinfo_template : PVisualInfo,
    nitems_return : PInt32
  ) : PVisualInfo

  fun get_wm_client_machine = XGetWMClientMachine(
    display : PDisplay,
    w : Window,
    text_prop_return : PTextProperty
  ) : Status

  fun get_wm_hints = XGetWMHints(
    display : PDisplay,
    w : Window
  ) : PWMHints

  fun get_wm_icon_name = XGetWMIconName(
    display : PDisplay,
    w : Window,
    text_prop_return : PTextProperty
  ) : Status

  fun get_wm_name = XGetWMName(
    display : PDisplay,
    w : Window,
    text_prop_return : PTextProperty
  ) : Status

  fun get_wm_normal_hints = XGetWMNormalHints(
    display : PDisplay,
    w : Window,
    hints_return : PSizeHints,
    supplied_return : PInt64,
  ) : Status

  fun get_wm_size_hints = XGetWMSizeHints(
    display : PDisplay,
    w : Window,
    hints_return : PSizeHints,
    supplied_return : PInt64,
    property : Atom
  ) : Status

  fun get_zoom_hints = XGetZoomHints(
    display: PDisplay,
    w : Window,
    zhints_return : PSizeHints
  ) : Status

  fun intersect_region = XIntersectRegion(
    sra : Region,
    srb : Region,
    dr_return : Region
  ) : Int32

  fun convert_case = XConvertCase(
    sym : KeySym,
    lower : PKeySym,
    upper : PKeySym
  ) : NoReturn

  fun lookup_string = XLookupString(
    event_struct : PKeyEvent,
    buffer_return : PChar,
    bytes_buffer : Int32,
    keysym_return : PKeySym,
    status_in_out : PComposeStatus
  ) : Int32

  fun match_visual_info = XMatchVisualInfo(
    display : PDisplay,
    screen : Int32,
    depth : Int32,
    c_class : Int32,
    vinfo_return : PVisualInfo
  ) : Status

  fun offset_region = XOffsetRegion(
    r : Region,
    dx : Int32,
    dy : Int32
  ) : Int32

  fun point_in_region = XPointInRegion(
    r : Region,
    x : Int32,
    y : Int32
  ) : Bool

  fun polygon_region = XPolygonRegion(
    points : PPoint,
    n : Int32,
    fill_rule : Int32
  ) : Region

  fun rect_in_region = XRectInRegion(
    r : Region,
    x : Int32,
    y : Int32,
    width : UInt32,
    height : UInt32
  ) : Int32

  fun save_context = XSaveContext(
    display : PDisplay,
    XID			/* rid */,
    XContext		/* context */,
    _Xconst char*	/* data */
) : Int32

extern int XSetClassHint(
  display : PDisplay,
  w : Window,
    XClassHint*		/* class_hints */
) : Int32

extern int XSetIconSizes(
  display : PDisplay,
  w : Window,
    XIconSize*		/* size_list */,
    int			/* count */
) : Int32

extern int XSetNormalHints(
  display : PDisplay,
  w : Window,
    XSizeHints*		/* hints */
) : Int32

extern void XSetRGBColormaps(
  display : PDisplay,
  w : Window,
    XStandardColormap*	/* stdcmaps */,
    int			/* count */,
    Atom		/* property */
) : NoReturn

extern int XSetSizeHints(
  display : PDisplay,
  w : Window,
    XSizeHints*		/* hints */,
    Atom		/* property */
) : Int32

extern int XSetStandardProperties(
  display : PDisplay,
  w : Window,
    _Xconst char*	/* window_name */,
    _Xconst char*	/* icon_name */,
    Pixmap		/* icon_pixmap */,
    char**		/* argv */,
    int			/* argc */,
    XSizeHints*		/* hints */
) : Int32

extern void XSetTextProperty(
  display : PDisplay,
  w : Window,
    XTextProperty*	/* text_prop */,
    Atom		/* property */
) : NoReturn

extern void XSetWMClientMachine(
  display : PDisplay,
  w : Window,
    XTextProperty*	/* text_prop */
) : NoReturn

extern int XSetWMHints(
  display : PDisplay,
  w : Window,
    XWMHints*		/* wm_hints */
) : Int32

extern void XSetWMIconName(
  display : PDisplay,
  w : Window,
    XTextProperty*	/* text_prop */
) : NoReturn

extern void XSetWMName(
  display : PDisplay,
  w : Window,
    XTextProperty*	/* text_prop */
) : NoReturn

extern void XSetWMNormalHints(
  display : PDisplay,
  w : Window,
    XSizeHints*		/* hints */
) : NoReturn

extern void XSetWMProperties(
  display : PDisplay,
  w : Window,
    XTextProperty*	/* window_name */,
    XTextProperty*	/* icon_name */,
    char**		/* argv */,
    int			/* argc */,
    XSizeHints*		/* normal_hints */,
    XWMHints*		/* wm_hints */,
    XClassHint*		/* class_hints */
) : NoReturn

extern void XmbSetWMProperties(
  display : PDisplay,
  w : Window,
    _Xconst char*	/* window_name */,
    _Xconst char*	/* icon_name */,
    char**		/* argv */,
    int			/* argc */,
    XSizeHints*		/* normal_hints */,
    XWMHints*		/* wm_hints */,
    XClassHint*		/* class_hints */
) : NoReturn

extern void Xutf8SetWMProperties(
  display : PDisplay,
  w : Window,
    _Xconst char*	/* window_name */,
    _Xconst char*	/* icon_name */,
    char**		/* argv */,
    int			/* argc */,
    XSizeHints*		/* normal_hints */,
    XWMHints*		/* wm_hints */,
    XClassHint*		/* class_hints */
) : NoReturn

extern void XSetWMSizeHints(
  display : PDisplay,
  w : Window,
    XSizeHints*		/* hints */,
    Atom		/* property */
) : NoReturn

extern int XSetRegion(
  display : PDisplay,
    GC			/* gc */,
    Region		/* r */
) : Int32

extern void XSetStandardColormap(
  display : PDisplay,
  w : Window,
    XStandardColormap*	/* colormap */,
    Atom		/* property */
) : NoReturn

extern int XSetZoomHints(
  display : PDisplay,
  w : Window,
    XSizeHints*		/* zhints */
) : Int32

extern int XShrinkRegion(
    Region		/* r */,
    int			/* dx */,
    int			/* dy */
) : Int32

extern Status XStringListToTextProperty(
    char**		/* list */,
    int			/* count */,
    XTextProperty*	/* text_prop_return */
) : Status

extern int XSubtractRegion(
    Region		/* sra */,
    Region		/* srb */,
    Region		/* dr_return */
) : Int32

extern int XmbTextListToTextProperty(
  display : PDisplay,
    char**		list,
    int			count,
    XICCEncodingStyle	style,
    XTextProperty*	text_prop_return
) : Int32

extern int XwcTextListToTextProperty(
  display : PDisplay,
    wchar_t**		list,
    int			count,
    XICCEncodingStyle	style,
    XTextProperty*	text_prop_return
) : Int32

extern int Xutf8TextListToTextProperty(
  display : PDisplay,
    char**		list,
    int			count,
    XICCEncodingStyle	style,
    XTextProperty*	text_prop_return
) : Int32

extern void XwcFreeStringList(
    wchar_t**		list
) : NoReturn

extern Status XTextPropertyToStringList(
    XTextProperty*	/* text_prop */,
    char***		/* list_return */,
    int*		/* count_return */
) : Status

extern int XmbTextPropertyToTextList(
  display : PDisplay,
    const XTextProperty* text_prop,
    char***		list_return,
    int*		count_return
) : Int32

extern int XwcTextPropertyToTextList(
  display : PDisplay,
    const XTextProperty* text_prop,
    wchar_t***		list_return,
    int*		count_return
) : Int32

extern int Xutf8TextPropertyToTextList(
  display : PDisplay,
    const XTextProperty* text_prop,
    char***		list_return,
    int*		count_return
) : Int32

extern int XUnionRectWithRegion(
    XRectangle*		/* rectangle */,
    Region		/* src_region */,
    Region		/* dest_region_return */
) : Int32

extern int XUnionRegion(
    Region		/* sra */,
    Region		/* srb */,
    Region		/* dr_return */
) : Int32

extern int XWMGeometry(
  display : PDisplay,
    int			/* screen_number */,
    _Xconst char*	/* user_geometry */,
    _Xconst char*	/* default_geometry */,
    unsigned int	/* border_width */,
    XSizeHints*		/* hints */,
    int*		/* x_return */,
    int*		/* y_return */,
    int*		/* width_return */,
    int*		/* height_return */,
    int*		/* gravity_return */
) : Int32

extern int XXorRegion(
    Region		/* sra */,
    Region		/* srb */,
    Region		/* dr_return */
) : Int32

end # module X11

require "./c/Xatom"

module X11
  include C

  # Predefined atoms.
  enum Atom : UInt64
    Primary            = XA_PRIMARY
    Secondary          = XA_SECONDARY
    Arc                = XA_ARC
    Atom               = XA_ATOM
    Bitmap             = XA_BITMAP
    Cardinal           = XA_CARDINAL
    Colormap           = XA_COLORMAP
    Cursor             = XA_CURSOR
    CutBuffer0         = XA_CUT_BUFFER0
    CutBuffer1         = XA_CUT_BUFFER1
    CutBuffer2         = XA_CUT_BUFFER2
    CutBuffer3         = XA_CUT_BUFFER3
    CutBuffer4         = XA_CUT_BUFFER4
    CutBuffer5         = XA_CUT_BUFFER5
    CutBuffer6         = XA_CUT_BUFFER6
    CutBuffer7         = XA_CUT_BUFFER7
    Drawable           = XA_DRAWABLE
    Font               = XA_FONT
    Integer            = XA_INTEGER
    Pixmap             = XA_PIXMAP
    Point              = XA_POINT
    Rectangle          = XA_RECTANGLE
    ResourceManager    = XA_RESOURCE_MANAGER
    RgbColorMap        = XA_RGB_COLOR_MAP
    RgbBestMap         = XA_RGB_BEST_MAP
    RgbBlueMap         = XA_RGB_BLUE_MAP
    RgbDefaultMap      = XA_RGB_DEFAULT_MAP
    RgbGrayMap         = XA_RGB_GRAY_MAP
    RgbGreenMap        = XA_RGB_GREEN_MAP
    RgbRedMap          = XA_RGB_RED_MAP
    String             = XA_STRING
    VisualID           = XA_VISUALID
    Window             = XA_WINDOW
    WmCommand          = XA_WM_COMMAND
    WmHints            = XA_WM_HINTS
    WmClientMachine    = XA_WM_CLIENT_MACHINE
    WmIconName         = XA_WM_ICON_NAME
    WmIconSize         = XA_WM_ICON_SIZE
    WmName             = XA_WM_NAME
    WmNormalHints      = XA_WM_NORMAL_HINTS
    WmSizeHints        = XA_WM_SIZE_HINTS
    WmZomHints         = XA_WM_ZOOM_HINTS
    MinSpace           = XA_MIN_SPACE
    NormSpace          = XA_NORM_SPACE
    MaxSpace           = XA_MAX_SPACE
    EndSpace           = XA_END_SPACE
    SuperscriptX       = XA_SUPERSCRIPT_X
    SuperscriptY       = XA_SUPERSCRIPT_Y
    SubscriptX         = XA_SUBSCRIPT_X
    SubscriptY         = XA_SUBSCRIPT_Y
    UnderlinePosition  = XA_UNDERLINE_POSITION
    UnderlineThickness = XA_UNDERLINE_THICKNESS
    StrikeoutAscent    = XA_STRIKEOUT_ASCENT
    StrikeoutDescent   = XA_STRIKEOUT_DESCENT
    ItalicAngle        = XA_ITALIC_ANGLE
    XHeight            = XA_X_HEIGHT
    QuadWidth          = XA_QUAD_WIDTH
    Weight             = XA_WEIGHT
    PointSize          = XA_POINT_SIZE
    Resolution         = XA_RESOLUTION
    Copyright          = XA_COPYRIGHT
    Notice             = XA_NOTICE
    FontName           = XA_FONT_NAME
    FamilyName         = XA_FAMILY_NAME
    FullName           = XA_FULL_NAME
    CapHeight          = XA_CAP_HEIGHT
    WmClass            = XA_WM_CLASS
    WmTransientFor     = XA_WM_TRANSIENT_FOR

    LastPredefined = XA_LAST_PREDEFINED

    # Returns self converted to UInt64.
    def to_u64 : UInt64
      self.value
    end
  end
end

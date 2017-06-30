module X11
  lib X
    alias PBOX = BOX*
    alias BOX = Box
    alias BoxRec = Box
    alias BoxPtr = Box*
    alias PBox = Box*

    struct Box
      x1, x2, y1, y2 : UInt16
    end

    alias RextangleRec = RECTANGLE
    alias RectanglePtr = RECTANGLE*

    struct RECTANGLE
      x, y, width, height : UInt16
    end

    TRUE     =     1
    FALSE    =     0
    MAXSHORT = 32767
    MINSHORT = -MAXSHORT

    # clip region
    alias PREGION = REGION*

    struct REGION
      size : Int64
      numRects : Int64
      rects : PBOX
      extents : BOX
    end

    # Xutil.cr contains the declaration:
    # alias _XRegion = Region*

    # number of points to buffer before sending them off
    # to scanlines() :  Must be an even number
    NUMPTSTOBUFFER = 200

    # used to allocate buffers for points and link
    # the buffers together
    alias PPOINTBLOCK = POINTBLOCK*

    struct POINTBLOCK
      pts : Point[NUMPTSTOBUFFER]
      next : PPOINTBLOCK
    end
  end # lib Xregion

  def self.max(a, b)
    a > b ? a : b
  end

  def self.min(a, b)
    a < b ? a : b
  end

  # 1 if two BOXs overlap.
  # 0 if two BOXs do not overlap.
  # Remember, x2 and y2 are not in the region
  def self.extent_check(r1, r2)
    r1.value.x2 > r2.value.x1 &&
      r1.value.x1 < r2.value.x2 &&
      r1.value.y2 > r2.value.y1 &&
      r1.value.y1 < r2.value.y2
  end

  # update region extents
  def self.extents(r, idRect)
    if r.value.x1 < idRect.value.extents.x1
      idRect.value.extents.x1 = r.value.x1
    end
    if r.value.y1 < idRect.value.extents.y1
      idRect.value.extents.y1 = r.value.y1
    end
    if r.value.x2 > idRect.value.extents.x2
      idRect.value.extents.x2 = r.value.x2
    end
    if r.value.y2 > idRect.value.extents.y2
      idRect.value.extents.y2 = r.value.y2
    end
  end

  # Check to see if there is enough memory in the present region.
  # def self.memcheck(reg, rect, firstrect)
  #  if reg.value.numRects >= reg.value.size - 1
  #    tmpRect = X11::realloc((firstrect), (2 * (sizeof(BOX)) * (reg.value.size)))
  #    if tmpRect.is_a(Nil)
  #      return 0
  #      firstrect = tmpRect
  #      reg.value.size *= 2
  #      rect = &firstrect[reg.value.numRects]
  #    end
  #  end
  # end

  # this routine checks to see if the previous rectangle is the same
  # or subsumes the new rectangle to add.
  def self.check_previous(reg, r, rx1, ry1, rx2, ry2)
    !((reg.value.numRects > 0) &&
      ((r - 1).value.y1 == ry1) &&
      ((r - 1).value.y2 == ry2) &&
      ((r - 1).value.x1 <= rx1) &&
      ((r - 1).value.x2 >= rx2))
  end

  # add a rectangle to the given Region
  def self.add_rect(reg, r, rx1, ry1, rx2, ry2)
    if (rx1 < rx2) && (ry1 < ry2) && self.check_previous(reg, r, rx1, ry1, rx2, ry2)
      r.value.x1 = rx1
      r.value.y1 = ry1
      r.value.x2 = rx2
      r.value.y2 = ry2
      self.extents(r, reg)
      reg.value.numRects = reg.value.numRects + 1
      r = r + 1
    end
  end

  # add a rectangle to the given Region
  def self.add_rect_nox(reg, r, rx1, ry1, rx2, ry2)
    if (rx1 < rx2) && (ry1 < ry2) && self.check_previous(reg, r, rx1, ry1, rx2, ry2)
      r.value.x1 = rx1
      r.value.y1 = ry1
      r.value.x2 = rx2
      r.value.y2 = ry2
      reg.value.numRects = reg.value.numRects + 1
      r = r + 1
    end
  end

  def self.empty_region(pReg)
    pReg.value.numRects = 0
  end

  def self.region_not_empty(pReg)
    pReg.value.numRects
  end

  def self.inbox(r, x, y)
    (r.x2 > x) &&
      (r.x1 <= x) &&
      (r.y2 > y) &&
      (r.y1 <= y)
  end
end # module X11

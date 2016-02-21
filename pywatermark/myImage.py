#!/usr/bin/python
# -*- coding: UTF-8 -*-

import Image, ImageEnhance

class myImage:
  def __init__(self, file, *args):
    self.image = Image.open(file, *args)
    if self.image.mode != "RGBA":
      self.image = self.image.convert("RGBA")

   
  def __getattr__(self, attr):
    if attr.startswith("__"): raise AttributeError
    return getattr(self.image, attr)


  def _txy(self, watermark, pos, offset): 
    wx, wy = watermark.size
    x, y   = self.image.size

    ty, tx = -1,-1

    if pos == "center":
      tx = int(x/2 - wx/2)
      ty = int(y/2 - wy/2)
#    elif pos == "tiled":
#      nx = int( x / ( wx + offset[0] ) )
#      ny = int( y / ( wy + offset[1] ) )
#
#      bx = int( ( ( x / ( wx + offset[0] ) ) % nx ) / 2)
#      by = int( ( ( y / ( wy + offset[0] ) ) % ny ) / 2)
    else:
      if pos[0] == "n" or pos[0] == "s":
        tx = int(x/2 - wx/2)
        if pos[0] == "n":        # norden
          ty = offset[1]
        else:                     # sueden
          ty = y - wy - offset[1]

      if pos[-1] == "e" or pos[-1] == "w":
        if ty < 0:
          ty = int(y/2 - wy/2)
        if pos[-1] == "e":       # osten
          tx = x - wx - offset[0]
        else:                     # westen
          tx = offset[0]

    return tx, ty;


  def watermark(self, watermark, pos, offset):
    mask = watermark.split()[3]
    self.image.paste(watermark, self._txy(watermark, pos, offset), mask)


  def opacity(self, opacity):
    """Returns an image with reduced opacity."""
    alpha = self.image.split()[3]
    alpha = ImageEnhance.Brightness(alpha).enhance(opacity/100.0)
    self.image.putalpha(alpha)

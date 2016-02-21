#!/usr/bin/python
# -*- coding: UTF-8 -*-

import getopt, sys, os
from myImage import myImage

class Cmdline:
  # defaults 
  offset   = 10, 10
  opacity  = 50
  threads  = 2
  position = "se"

  def usage(self, s1=None, s2=None):
    if s1 and s2:
      print "Ungültiges Argument für --%s: %s\n" % (s1, s2)

    print """%s --watermark=/path/to/file.png [--opacity=30 --offset=20,10 ] /files/
  --watermark:
    Pfad zu dem Bild, das als Wasserzeichen verwendet werden soll
  --offset:
    horizontaler, vertikaler Abstand von der unteren rechten Ecke bis zum
    Wasserzeichen in Pixeln (Standard: 10,10)
  --opacity:
    Deckungskraft des Bildes in Prozent (Standard: 50)
  --threads:
    Anzahl der gleichzeitig laufenden Threads (Stadard: 2)
    Um auf Mehrprozessorsystemen alle Prozessoren auszunutzen, müssen
    (mindestens) so viele Threads wie verfügbare Prozessorkerne gestartet
    werden
  --position:
    Position des Wasserzeichens im Bild: n,ne,e,se,s,sw,w,nw,center
      n:      oben
      e:      rechts
      s:      unten
      w:      links
      center: zentriert (Standard: se)
  --help:
    gibt diesen Hilfetext aus""" % sys.argv[0]

    sys.exit()


  def __init__(self, args):
    try:
      long_opts = "watermark=", "opacity=", "offset=", "threads=", "position=", "help"
      optlist, images = getopt.gnu_getopt(args, "-h", long_opts)
    except getopt.GetoptError:
      self.usage()

    temp = {}
    for i in images:
      temp[i] = 1
    self.images = temp.keys()

    self.optdict = dict(optlist)
    self.parse()

  def parse(self):
    optdict = self.optdict
    usage   = self.usage

    if optdict.has_key("--help") or optdict.has_key("-h"):
      usage()

    # offset
    if optdict.get("--offset"):
      offset = optdict.get("--offset")

      try:
        if offset.find(",") != -1:
          x,y = offset.split(",", 1)
          self.offset = int(x), int(y)
        else:
          self.offset = int(offset)
      except ValueError:
        usage("offset", offset)

    # opacity
    if optdict.get("--opacity"):
      opacity = optdict.get("--opacity")
      
      try:
        self.opacity = int(opacity)
      except ValueError:
        usage("opacity", opacity)

      if not 0 <= opacity <= 100:
        usage("opacity", opacity)

    # threads
    if optdict.get("--threads"):
      threads = optdict.get("--threads")
      
      try:
        self.threads = int(threads)
      except ValueError:
        usage("threads", threads)

    # position
    if optdict.get("--position"):
      self.position = optdict.get("--position")
      
    if not self.position in ("n", "ne", "e", "se", "s", "sw", "w", "nw", "center", "tiled"):
      usage("position", position)

    # watermark
    if optdict.get("--watermark"):
      self.watermark = optdict.get("--watermark")

      if not os.path.exists(self.watermark):
        usage("watermark", '"' + watermark + '"' + " existiert nicht")
    else:
      usage("watermark", "kein Argument übergeben")


options   = Cmdline(sys.argv[1:])

watermark = myImage(options.watermark)
watermark.opacity(options.opacity)

i       = 0
total   = len(options.images)
fstring = "[%" + str(len(str(total))) + "d/" + str(total) + "] %s..."

try:
  for file in options.images:
    i += 1
    print fstring % (i, file),
    im = myImage(file)
    im.watermark(watermark, options.position, options.offset)
    im.save(file)
    print " ok."
except KeyboardInterrupt:
  print "\nAbgebrochen."
  sys.exit(1)

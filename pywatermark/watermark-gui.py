#!/usr/bin/python
# -*- coding: UTF-8 -*-

# Copyright (c) 2008, Michael Hartmann <michael@speicherleck.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# "Trying is the first step towards failure." -- Homer Simpson

exit = 0
from myImage   import myImage
from threading import Thread
import os, stat, sys

try:
  import Image
except:
  print >> sys.stderr, "Python-Imaging (PIL) ist nicht installiert:"
  print >> sys.stderr, "  PIL ist notwendig, damit dass Programm lauffähig ist."
  print >> sys.stderr, "  Bitte installieren Sie PIL, um dieses Programm nutzen zu können."
  exit = 1;

try:
  import pygtk
  pygtk.require("2.0")
  import gtk, gtk.glade, gobject
except:
  print >> sys.stderr, "PyGTK (mindestens Version 2.0) ist nicht installiert:"
  print >> sys.stderr, "  PyGTK ist notwendig, damit dieses Programm lauffähig ist."
  print >> sys.stderr, "  Bitte installieren Sie PyGTK, um dieses Programm nutzen zu können"
  exit = 1

if exit == 1:
  sys.exit(1)
del exit

class Gui: pass

class Gui(Thread):
  dir   = ""
  index = sys.argv[0].rfind(os.sep)
  if index != -1:
    dir = sys.argv[0][:index+1]

  gladefile  = dir + "gui.glade"
  widgetTree = gtk.glade.XML(gladefile)


  class ImageList:
    def __init__(self):
      self.files_in_list = {}

    def init(self):
      gstr = gobject.TYPE_STRING
      liststore = gtk.ListStore(gstr, gstr, gstr, gstr, gstr)
      
      bottom = Gui.Bottom()
      def f(*l): bottom.check_sensitive()
      for signal in ("row-inserted", "row-deleted"):
        liststore.connect(signal, f)

      treeview = Gui.widgetTree.get_widget("treeview")
      treeview.set_model(liststore);

      i = 1
      for text in ("Name", "Größe", "Abmessungen", "Typ"):
        column   = gtk.TreeViewColumn()
        renderer = gtk.CellRendererText()
        column.set_title(text);
        column.pack_start(renderer, False);
        column.add_attribute(renderer, "text", i);
        treeview.append_column(column);
        i += 1

      self.add(sys.argv[1:])


    def get_selected(self):
      treeview = Gui.widgetTree.get_widget("treeview")
      treeselection = treeview.get_selection()
      return treeselection.get_selected() # (model, iter)


    def get_all(self, i=0):
      treeview = Gui.widgetTree.get_widget("treeview")
      model = treeview.get_model()

      values = []
      model.foreach(lambda m,p,giter: values.append(model.get_value(giter, 0)))
      return values


    def add(self, files):
      treeview  = Gui.widgetTree.get_widget("treeview")
      liststore = treeview.get_model()
      incompatible = []

      for file in files:
        basename = file[file.rfind(os.sep)+1:]
        ext      = file[file.rfind(".")+1:].lower()

        if self.files_in_list.has_key(file): break

        def bytes2human(i):
          k = 1024
          if   i < k:
            return "%d Bytes"
          elif i < k**2:
            return "%.0f KiB" % (i/k)
          else:
            return "%.0f MiB" % (i/k**2)
            
        try:
          img = Image.open(file)
          (width, height) = img.size
          imgsize  = str(width) + "x" + str(height)
          filesize = bytes2human(os.stat(file).st_size)
          self.files_in_list[file] = 1
        except:
          incompatible.append(file)
          break

        giter = liststore.append()
        liststore.set(giter,
          0, file,
          1, basename,
          2, filesize,
          3, imgsize,
          4, ext
        )


    def remove(self, giter=None):
      if not giter: return

      treeview  = Gui.widgetTree.get_widget("treeview")
      liststore = treeview.get_model()

      file = treeview.get_model().get_value(giter, 0);
      liststore.remove(giter)
      del self.files_in_list[file]


    def clear(self):
      treeview  = Gui.widgetTree.get_widget("treeview")
      liststore = treeview.get_model()

      liststore.clear()
      self.files_in_list = {}


    def button_add(self):
      chooser = gtk.FileChooserDialog("Dateien auswählen", Gui.widgetTree.get_widget("window"))
      chooser.set_select_multiple(True)
      chooser.set_default_response(gtk.RESPONSE_OK)
      chooser.add_button(gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL)
      chooser.add_button(gtk.STOCK_OPEN, gtk.RESPONSE_OK) 
      response = chooser.run()
      if response == gtk.RESPONSE_OK:
        self.add(chooser.get_filenames())
      chooser.destroy()

      return True


    def button_remove(self):
      model, giter = self.get_selected()

      return self.remove(giter);


    def button_clear(self):
      self.clear()


  class Notebook:
    def __init__(self):
      self.watermark = Gui.widgetTree.get_widget("filechooserbutton_watermark")
      self.position  = Gui.widgetTree.get_widget("combobox_position")
      self.opacity   = Gui.widgetTree.get_widget("spinbutton_opacity")
      self.voffset   = Gui.widgetTree.get_widget("spinbutton_voffset")
      self.hoffset   = Gui.widgetTree.get_widget("spinbutton_hoffset")
      self.overwrite = Gui.widgetTree.get_widget("checkbutton_overwrite")
      self.outputdir = Gui.widgetTree.get_widget("filechooserbutton_outputdir")

      self.overwrite.connect("clicked",  lambda *l: self.outputdir.set_sensitive(not self.overwrite.get_active()))
      bottom = Gui.Bottom()
      self.watermark.connect("selection-changed", lambda *l: bottom.check_sensitive())


    def init(self):
      gstr = gobject.TYPE_STRING
      self.liststore = gtk.ListStore(gstr, gstr)

      for line in [
        ("nw"    , "oben, links"  ),
        ("nm"    , "oben, mittig" ),
        ("ne"    , "oben, rechts" ),

        ("mw"    , "mitte, links"  ),
        ("center", "mittig"       ),
        ("me"    , "mitte, rechts" ),

        ("sw"    , "unten, links" ),
        ("sm"    , "unten, mittig"),
        ("se"    , "unten, rechts")
      ]:
        giter = self.liststore.append()
        self.liststore.set(giter, 0, line[0], 1, line[1])


      self.position.clear()
      self.position.set_model(self.liststore)
      renderer = gtk.CellRendererText()
      self.position.pack_start(renderer, False)
      self.position.add_attribute(renderer, "text", 1)
      self.position.set_active(8);

  class Bottom:
    def __init__(self):
      self.progressbar = Gui.widgetTree.get_widget("progressbar")
      self.convert     = Gui.widgetTree.get_widget("button_convert")

    def check_sensitive(self):
      n = len(Gui.widgetTree.get_widget("treeview").get_model())
      w = Gui.widgetTree.get_widget("filechooserbutton_watermark").get_filename()
      self.convert.set_sensitive(n > 0)


  def __init__(self):
    Thread.__init__(self)

    self.widgetTree.get_widget("window").show_all()
    self.connect()

    self.ImageList = Gui.ImageList()
    self.Notebook  = Gui.Notebook()
    self.ImageList.init()
    self.Notebook .init()

  def connect(self):
    tree = self.widgetTree

    tree.get_widget("window").connect("delete_event", gtk.main_quit)

    tree.get_widget("button_add")    .connect("clicked", lambda *l: self.ImageList.button_add()   )
    tree.get_widget("button_remove") .connect("clicked", lambda *l: self.ImageList.button_remove())
    tree.get_widget("button_clear")  .connect("clicked", lambda *l: self.ImageList.button_clear() )

    tree.get_widget("button_convert").connect("clicked", lambda *l: self.start())

  def run(self):
    gtk.gdk.threads_enter()
    tree = self.widgetTree

    button_convert     = tree.get_widget("button_convert")
    filechooserbutton  = tree.get_widget("filechooserbutton_watermark")
    spinbutton_opacity = tree.get_widget("spinbutton_opacity")
    combobox_position  = tree.get_widget("combobox_position")
    treeview           = tree.get_widget("treeview")
    spinbutton_hoffset = tree.get_widget("spinbutton_hoffset")
    spinbutton_voffset = tree.get_widget("spinbutton_voffset")
    progressbar        = tree.get_widget("progressbar")

    checkbutton_overwrite       = tree.get_widget("checkbutton_overwrite")
    filechooserbutton_outputdir = tree.get_widget("filechooserbutton_outputdir")

    button_convert.set_sensitive(False)
    progressbar.set_fraction(0.0)
    progressbar.set_text("0,0%")
    
    watermark = myImage(filechooserbutton.get_filename())
    watermark.opacity(spinbutton_opacity.get_value_as_int())

    imagelist  = Gui.ImageList()
    images     = imagelist.get_all()
    giter      = combobox_position.get_active_iter()
    position   = combobox_position.get_model().get_value(giter, 0)

    offset     = (spinbutton_hoffset.get_value_as_int(), spinbutton_voffset.get_value_as_int())
    
    if checkbutton_overwrite.get_active():
      outputfile = file
    else:
      outputfile = filechooserbutton_outputdir.get_filename()
    gtk.gdk.threads_leave()

    i       = 0
    total   = len(images)

    for file in images:
      i += 1 # aka i++! 6 zeichen vs 3
      im = myImage(file)
      im.watermark(watermark, position, offset)
      im.save(outputfile)

      gtk.gdk.threads_enter()
      frac = float(i)/total
      progressbar.pulse()
      progressbar.set_fraction(frac)
      progressbar.set_text("%.1f%%" % (frac * 100))
      gtk.gdk.threads_leave()

    gtk.gdk.threads_enter()
    button_convert.set_sensitive(True)
    gtk.gdk.threads_leave()


#gtk.gdk.threads_init()
gui = Gui()
gtk.main()

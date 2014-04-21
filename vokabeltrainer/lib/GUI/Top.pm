package GUI::Top;

use warnings;
use strict;

sub new {
  my $self = bless {};
  
  $self->{uimanager} = Gtk2::UIManager->new;

  $::gui{window}->get_window->add_accel_group($self->{uimanager}->get_accel_group);

  $self->{menu_actions} = Gtk2::ActionGroup->new("menu_actions");
  $self->{menu_actions}->add_actions(
    [
      # [ name, stock_id, value, label, accelerator, tooltip, callback ]
   
      # file
      [ "FileMenu",     "file",   "_Datei", ],
      [ "import_units", 'import', "_Importieren",   undef,        undef, sub { warn 1; } ],
      [ "export_units", 'export', "_Exportieren",   undef,        undef, sub { warn 2; } ],
      [ "quit",         'quit',   "_Beenden",       "<control>q", undef, sub { quit(); } ],

      # language
      [ "LanguagesMenu",    "language", "_Sprache" ],
      [ "add_language",    "add",      "Hinzufügen", undef, undef, sub { add_language();    } ],
      [ "rename_language", "edit",     "Umbennen",   undef, undef, sub { rename_language(); } ],
      [ "delete_language", "delete",   "Entfernen",  undef, undef, sub { delete_language()  } ],

      # units
      [ "UnitsMenu",   "unit", "_Lektion" ],
      [ "edit_units", "edit", "Bearbeiten", undef, undef, sub { warn 6; } ],

      # vocable
      [ "VocablesMenu",         "vocabulary", "_Vokabeln" ],
      [ "insert_vocables",      "add", "Hinzufügen",        undef, undef, sub { warn 7; } ],
      [ "edit_vocables",        "edit", "Bearbeiten",       undef, undef, sub { warn 8; } ],
      [ "search_vocables",      "mag", "Suchen",            undef, undef, sub { warn 8; } ],
      [ "test_unit",            "quiz", "Lektion abfragen", undef, undef, sub { test_unit(); } ],
      [ "test_multiple_choice", "quiz", "Multiple Choice",  undef, undef, sub { warn 11; } ],
      [ "test_mixed",           "quiz", "Vokabelmixer",     undef, undef, sub { warn 10; } ],

      # settings
      [ "SettingsMenu",    "gear",     "_Einstellungen" ],
      [ "change_settings", "settings", "Bearbeiten",        undef, undef, sub { warn 12 } ],
      [ "show_protocol",   "protocol", "Protokol einsehen", undef, undef, sub { warn 13 } ],

      # help
      [ "HelpMenu", "help", "_Hilfe" ],
      [ "help",     "help", "Hilfe",   undef, undef, sub { warn "foo" } ],
      [ "about",    "info", "Über...", undef, undef, sub { about(); } ]
    ], undef);

    $self->{uimanager}->insert_action_group($self->{menu_actions}, 0);

    $self->{uimanager}->add_ui_from_string(
<<XML
<ui>
  <menubar name='MenuBar'>
      <menu action='FileMenu'>
        <menuitem action='import_units' />
        <menuitem action='export_units' />
        <separator/>
        <menuitem action='quit'/>
      </menu>
      
      <menu action='LanguagesMenu'>
        <menuitem action='add_language' />
        <menuitem action='rename_language' />
        <menuitem action='delete_language' />
      </menu>
      
      <menu action='UnitsMenu'>
        <menuitem action='edit_units'   />
      </menu>
      
      <menu action='VocablesMenu'>
        <menuitem action='insert_vocables'  />
        <menuitem action='edit_vocables' />
        <separator />
        <menuitem action='search_vocables' />
        <separator />
        <menuitem action='test_unit' />
        <menuitem action='test_mixed' />
        <menuitem action='test_multiple_choice' />
      </menu>
      
      <menu action='SettingsMenu'>
        <menuitem action='change_settings' />
        <menuitem action='show_protocol'   />
      </menu>
      
      <menu action='HelpMenu'>
        <menuitem action='help' />
        <separator />
        <menuitem action='about'   />
      </menu>
  </menubar>
  
  <toolbar name='Toolbar'>
     <toolitem  action='test_unit'/>
     <toolitem  action='test_mixed'/>
     <separator />
     <toolitem  action='search_vocables'/>
     <separator />
     <toolitem  action='show_protocol'/>
     <separator />
     <toolitem  action='quit'/>
  </toolbar>
  </ui> 
XML
  );

  return $self;
}

sub get_uimanager {
  my $self = shift;
  return $self->{uimanager};
}

sub add_language {
  GUI::Language::Add->new;
}

sub rename_language {
  GUI::Language::Rename->new($::gui{left}->get_selected);
}

sub delete_language {
  GUI::Language::Delete->new($::gui{left}->get_selected);
}

sub test_unit {
  GUI::Test->new($::gui{left}->get_selected);
}

sub about {
  GUI::About->new;
}

sub quit {
  $::gui{window}->destroy;
}

1;

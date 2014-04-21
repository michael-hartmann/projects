#!/usr/bin/perl

use utf8;
use warnings;
use strict;

use lib "./lib";

use Glib qw< TRUE FALSE >;
use Gtk2 qw< -init      >;

use GUI::Window;
use GUI::Top;
use GUI::Left;
use GUI::Right;
use GUI::Bottom;
use GUI::Test;
use GUI::About;
use GUI::Language::Add;
use GUI::Language::Rename;
use GUI::Language::Delete;

use Log;
use Settings;
use Vocabulary;

# use YAML::Syck;
BEGIN {
  eval {
    require YAML::Syck and import YAML::Syck qw< LoadFile Dump >;
  };

  if($@) {
    print STDERR "Verwende YAML anstatt von YAML::Syck.\n";
    print STDERR "Installieren sie für (viel) bessere Performance YAML::Syck auf ihrem Rechner.\n";
    require YAML;
    import YAML qw< LoadFile Dump >;
  }
}

our $settings = Settings->new;
our $voc      = Vocabulary->new;

our %gui;
$gui{window} = GUI::Window->new;
$gui{top}    = GUI::Top->new;
$gui{left}   = GUI::Left->new;
$gui{right}  = GUI::Right->new;
$gui{bottom} = GUI::Bottom->new;

my $vbox = Gtk2::VBox->new(FALSE, 0);
$gui{window}->get_window->add($vbox);

# add menu and toolbar
$vbox->pack_start($gui{top}->get_uimanager->get_widget('/MenuBar'), FALSE, FALSE, 0);
$vbox->pack_start($gui{top}->get_uimanager->get_widget('/Toolbar'), FALSE, FALSE, 0);

my $hbox = Gtk2::HBox->new(FALSE, 5);
$vbox->pack_start($hbox, TRUE, TRUE, 5);

$hbox->set_border_width(5);
$hbox->pack_start($gui{left}->get_frame, TRUE, TRUE, 5);
$hbox->pack_start($gui{right}->get_vbox, TRUE, TRUE, 0);

$vbox->pack_start($gui{bottom}->get_statusbar, TRUE, TRUE, 5);

$gui{bottom}->push(
  0 => sprintf (
    "%d Sprachen, %d Lektionen, insgesamt %d Vokabeln geladen",
    scalar $voc->get_languages, scalar $voc->get_units, $voc->count_vocables
  )
); 

$gui{window}->get_window->show_all;
Gtk2->main;

$voc->save;

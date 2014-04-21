package GUI::Language::Delete;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};
  
  $self->{language} = $_[1] || return;
  
  $self->{dialog} = Gtk2::Dialog->new(
    "Sprache entfernen", 
    $::gui{window}->get_window, [ "modal" ]
  );

  $self->{dialog}->set_resizable(FALSE);

  $self->{vbox} = $self->{dialog}->vbox;
  
  $self->{frame1} = Gtk2::Frame->new("Information");
  $self->{frame1}->set_border_width(5);
  $self->{vbox}->pack_start($self->{frame1}, TRUE, TRUE, 5);

  $self->{info_label} = Gtk2::Label->new("foobar " x20);
  $self->{info_label}->set_line_wrap(TRUE);
  $self->{frame1}->add($self->{info_label});
 
  $self->{frame2} = Gtk2::Frame->new("Sprache entfernen");
  $self->{frame2}->set_border_width(5);
  $self->{vbox}->pack_start($self->{frame2}, TRUE, TRUE, 5);

  $self->{label} = Gtk2::Label->new;
  $self->{label}->set_text("Soll die Sprache $self->{language} entfernt werden?");
  $self->{frame2}->add($self->{label});

  $self->{button_ok} = Gtk2::Button->new("Ja");
  $self->{button_ok}->set_image(Gtk2::Image->new_from_stock("ok", "button"));
  $self->{button_ok}->signal_connect(clicked => sub {
    $::voc->delete_language($self->{language});
    $::gui{bottom}->push(3 => "Sprache \"$self->{language}\" entfernt");
    $self->{dialog}->destroy;
  });
  
  $self->{button_abort} = Gtk2::Button->new("Nein");
  $self->{button_abort}->set_image(Gtk2::Image->new_from_stock("cancel", "button"));
  $self->{button_abort}->signal_connect(clicked => sub { $self->{dialog}->destroy });

  $self->{dialog}->add_action_widget($self->{button_abort}, 1);
  $self->{dialog}->add_action_widget($self->{button_ok}, 1);

  $self->{dialog}->show_all;

  return $self->{dialog}->run;
}

1;

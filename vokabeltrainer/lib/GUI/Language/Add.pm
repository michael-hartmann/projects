package GUI::Language::Add;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};

  $self->{dialog} = Gtk2::Dialog->new(
    "Sprache hinzufügen", 
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
 
  $self->{frame2} = Gtk2::Frame->new("Name der neuen Sprache");
  $self->{frame2}->set_border_width(5);
  $self->{vbox}->pack_start($self->{frame2}, TRUE, TRUE, 5);

  $self->{entry} = Gtk2::Entry->new;
  $self->{frame2}->add($self->{entry});
  $self->{entry}->set_activates_default(TRUE);
  $self->{entry}->signal_connect(changed => sub { 
    # ok button only sensitive, when text in entry widget longer than 0 chars
    # and there is not yet a language with the same name
    $self->{button_ok}->set_sensitive(
      $self->{entry}->get_text      
        ? not defined $::voc->get_units($self->{entry}->get_text)
        : FALSE
    );
  });

  $self->{button_ok} = Gtk2::Button->new("OK");
  $self->{button_ok}->set_sensitive(FALSE);
  $self->{button_ok}->set_image(Gtk2::Image->new_from_stock("ok", "button"));
  $self->{button_ok}->can_default(TRUE);
  $self->{dialog}->add_action_widget($self->{button_ok}, 1);
  $self->{button_ok}->grab_default;
  $self->{button_ok}->signal_connect(clicked => sub {
    my $language = $self->{entry}->get_text;
    $::voc->add_language($language);
    $::gui{bottom}->push(3 => "Sprache \"$language\" erstellt");
    $self->{dialog}->destroy;
  });
  
  $self->{button_abort} = Gtk2::Button->new("Abbrechen");
  $self->{button_abort}->set_image(Gtk2::Image->new_from_stock("cancel", "button"));
  $self->{button_abort}->signal_connect(clicked => sub { $self->{dialog}->destroy });
  $self->{dialog}->add_action_widget($self->{button_abort}, 2);

  $self->{dialog}->show_all;

  return $self->{dialog}->run;
}

1;

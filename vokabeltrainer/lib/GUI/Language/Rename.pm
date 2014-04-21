package GUI::Language::Rename;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};
  
  # this is the language we want to rename
  $self->{language} = $_[1] || return; 

  $self->{dialog} = Gtk2::Dialog->new(
    "Sprache umbennen",
    $::gui{window}->get_window, [ qw/modal destroy-with-parent/ ]
  );

  $self->{dialog}->set_resizable(FALSE);

  $self->{vbox} = $self->{dialog}->vbox;
  
  $self->{frame1} = Gtk2::Frame->new("Information");
  $self->{frame1}->set_border_width(5);
  $self->{vbox}->pack_start($self->{frame1}, TRUE, TRUE, 5);

  $self->{info_label} = Gtk2::Label->new("foobar " x20);
  $self->{info_label}->set_line_wrap(TRUE);
  $self->{frame1}->add($self->{info_label});
 
  $self->{frame2} = Gtk2::Frame->new("Name der Sprache");
  $self->{frame2}->set_border_width(5);
  $self->{vbox}->pack_start($self->{frame2}, TRUE, TRUE, 5);

  $self->{entry} = Gtk2::Entry->new;
  $self->{entry}->set_activates_default(TRUE);
  $self->{entry}->set_text($self->{language}) if $self->{language};
  $self->{frame2}->add($self->{entry});
  $self->{entry}->signal_connect(changed => sub {
    # ok button only sensitive, when text in entry widget longer than 0 chars
    # and there is not yet a language with the same ame
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
    my ($old, $new) = ($self->{language}, $self->{entry}->get_text);
    $::voc->rename_language($old => $new);
    $::gui{bottom}->push(3 => "Sprache \"$old\" in \"$new\" umbennant");
    $self->{dialog}->destroy;
  });

  $self->{button_undo} = Gtk2::Button->new("Zurücksetzen");
  $self->{button_undo}->set_image(Gtk2::Image->new_from_stock("undo", "button"));
  $self->{button_undo}->signal_connect(clicked => sub {
    $self->{entry}->set_text($self->{language});
  });
  $self->{dialog}->add_action_widget($self->{button_undo}, 1);
  
  $self->{button_abort} = Gtk2::Button->new("Abbrechen");
  $self->{button_abort}->set_image(Gtk2::Image->new_from_stock("cancel", "button"));
  $self->{button_abort}->signal_connect(clicked => sub { $self->{dialog}->destroy });
  $self->{dialog}->add_action_widget($self->{button_abort}, 1);


  $self->{dialog}->show_all;

  return $self->{dialog}->run;
}

1;

package GUI::Test::Incorrect;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my ($native, $correct, $incorrect) = @_[1,2,3];
  my $self = bless {};

  $self->{dialog} = Gtk2::Dialog->new(
    "Fehler", 
    $::gui{window}->get_window, [ "modal" ]
  );

  $self->{dialog}->set_resizable(FALSE);

  $self->{vbox1} = $self->{dialog}->vbox;
  
  $self->{frame1} = Gtk2::Frame->new("Information");
  $self->{frame1}->set_border_width(5);
  $self->{vbox1}->pack_start($self->{frame1}, TRUE, TRUE, 5);

  $self->{info_label} = Gtk2::Label->new("foobar " x20);
  $self->{info_label}->set_line_wrap(TRUE);
  $self->{frame1}->add($self->{info_label});
 
  $self->{frame2} = Gtk2::Frame->new("Fehler");
  $self->{frame2}->set_border_width(5);
  $self->{vbox1}->pack_start($self->{frame2}, FALSE, FALSE, 5);

  $self->{hbox} = Gtk2::HBox->new(FALSE, 5);
  $self->{frame2}->add($self->{hbox});

  $self->{image} = Gtk2::Image->new_from_stock("error", "large-toolbar");
  $self->{hbox}->pack_start($self->{image}, TRUE, TRUE, 5);

 
  # table
  {
    $self->{label2} = Gtk2::Label->new;
    $self->{label2}->set_markup(sprintf "<span foreground='green'>%s</span>", join ", ", @$correct);
    
    $self->{label3} = Gtk2::Label->new;
    $self->{label3}->set_markup(sprintf "<span foreground='red'>%s</span>", $incorrect);
    
    $self->{table} = Gtk2::Table->new(2, 2, FALSE);
    $self->{hbox}->pack_start($self->{table}, TRUE, TRUE, 5);
    
    $self->{table}->attach_defaults(
      Gtk2::Label->new(join ", ", @$native), 0, 2, 0, 1
    );
    
    $self->{table}->attach_defaults(
      Gtk2::Label->new("Richtig:"), 0, 1, 1, 2
    );
    $self->{table}->attach_defaults(
      $self->{label2}, 1, 2, 1, 2
    );
    
    $self->{table}->attach_defaults(
      Gtk2::Label->new("Falsch:"), 0, 1, 2, 3
    );
    $self->{table}->attach_defaults(
      $self->{label3}, 1, 2, 2, 3
    );
  }
  
  $self->{button_ok} = Gtk2::Button->new("OK");
  $self->{button_ok}->set_image(Gtk2::Image->new_from_stock("ok", "button"));
  $self->{button_ok}->signal_connect(clicked => sub {
    $self->{dialog}->destroy;
  });
  $self->{dialog}->add_action_widget($self->{button_ok}, 1);
  
  $self->{dialog}->show_all;
  return $self->{dialog}->run;
}

1;

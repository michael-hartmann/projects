package GUI::Window;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw< TRUE FALSE >;

use File::Basename;

sub new {
  my $self = bless {};

  $self->{window} = Gtk2::Window->new;
  $self->{window}->set_title("fooBAR");
  $self->{window}->set_resizable(FALSE);

  $self->{factory} = Gtk2::IconFactory->new();
  
  foreach my $icon (glob "icons/*.png") {
    my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file($icon);
    my $set = Gtk2::IconSet->new_from_pixbuf($pixbuf);

    $self->{factory}->add(basename($icon, ".png"), $set);
  }
  $self->{factory}->add_default();

  $self->{window}->signal_connect("delete-event" => sub { $self->destroy; }); 
  
  return $self;
}

sub get_window {
  my $self = shift;
  return $self->{window};
}

sub destroy {
  my $self = shift;
  $self->{window}->hide; # hack
  Gtk2->main_quit; 
}

1;

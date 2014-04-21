package GUI::Test::Info;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};

  $self->{frame} = Gtk2::Frame->new("Informationen");
  $self->{frame}->set_border_width(5);

  $self->{hbox}  = Gtk2::HBox->new(FALSE, 5);
  $self->{frame}->add($self->{hbox});

  $self->{image} = Gtk2::Image->new_from_stock("info", "large-toolbar");
  $self->{hbox}->pack_start($self->{image}, FALSE, FALSE, 5);
  
  $self->{label} = Gtk2::Label->new("foobar "x22);
  $self->{label}->set_line_wrap(TRUE);
  $self->{hbox}->pack_start($self->{label}, FALSE, TRUE, 5);

  return $self;
}

sub get_frame {
  my $self = shift;
  return $self->{frame};
}

1;

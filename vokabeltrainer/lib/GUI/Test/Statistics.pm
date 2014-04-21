package GUI::Test::Statistics;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};
    
  $self->{frame} = Gtk2::Frame->new("Statistik");
  $self->{frame}->set_border_width(5);

  $self->{hbox} = Gtk2::HBox->new(FALSE, 5);
  $self->{frame}->add($self->{hbox});

  $self->{image} = Gtk2::Image->new_from_stock("star", "large-toolbar");
  $self->{hbox}->pack_start($self->{image}, FALSE, FALSE, 5);
  
  $self->{table} = Gtk2::Table->new(4, 2, FALSE);
  $self->{hbox}->pack_start($self->{table}, FALSE, FALSE, 5);
 
  $self->{table}->set_col_spacings(5);

  {
    my $i = 0;
    foreach my $text ("Vokabel:", "richtig:", "falsch:", "Durchschnitt:") {
      my $label = Gtk2::Label->new($text);
      $label->set_alignment(0, 0);
      $self->{table}->attach_defaults(
        $label,
        0, 1, $i, $i+1,
      );
      $i++;
    }
  }

  # all rows, right column
  foreach my $i (0..3) {
    $self->{label}->[$i] = Gtk2::Label->new,
    $self->{label}->[$i]->set_alignment(0, 0);
    $self->{table}->attach_defaults(
      $self->{label}->[$i],
      1, 2, $i, $i+1,
    );
  }

  return $self;
}
 
sub set_markup {
  my ($self, $i, $text) = @_;

  $self->{label}->[$i]->set_markup($text) || return;
  return 1;
}

sub get_frame {
  my $self = shift;

  return $self->{frame};
}

1;

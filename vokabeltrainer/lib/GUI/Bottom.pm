package GUI::Bottom;

use utf8;
use warnings;
use strict;

use Glib qw< TRUE FALSE >;
use Gtk2 qw< -init      >;

sub new {
  my $self = bless {};
  $self->{statusbar} = Gtk2::Statusbar->new;

  return $self;
}

sub push {
  my $self = shift;
  $self->{statusbar}->push(@_);
}

sub pop {
  my $self = shift;
  $self->{statusbar}->pop(@_);
}

sub get_statusbar {
  my $self = shift;
  return $self->{statusbar};
}

1;

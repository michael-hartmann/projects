package Game::Card;

use warnings;
use strict;
use utf8;

use Settings;

sub new {
  my ($class, $set) = (shift, shift);

  my $self = bless { set => $set }, $class;

  my $file = $self->{file} = shift;

  my $settings = Settings->new;
  my $cover = $self->{set} = $settings->get("cover");
  $self->{cover} = "covers/$cover.jpg";
  $self->{image} = "sets/$set/$file.jpg";

  return $self;
}

sub get_id   { $_[0]->{file} }
sub get_file { $_[0]->{file} }

sub get_set {
  my $self = shift;

  return $self->{set};
}

sub compare {
  my ($obj1, $obj2) = @_;

  return 1 if
    $obj1->{file} eq $obj2->{file} and
    $obj1         ne $obj2;
  return;
}

sub hide {
  my $self = shift;

  $self->{shown} = 0;
  return Gtk2::Image->new_from_file($self->{cover});
  return $self->{cover};
}

sub unhide {
  my $self = shift;

  $self->{shown} = 1;
  return Gtk2::Image->new_from_file($self->{image});
  return $self->{image};
}

sub shown {
  return $_[0]->{shown};
}

1;

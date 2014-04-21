package Game::Cards;

use warnings;
use strict;
use utf8;

use File::Basename qw< basename >;
use Game::Card;
use List::Util     qw< shuffle  >;
use Settings;

my %sets;
{
  open my $fh, "<", "sets.cfg" or die "Can't open sets.cfg: $!";
  while(my $line = <$fh>) { 
    next unless $line =~ /:/;
    chomp $line;
    my ($key, $value) = split /:\s*/, $line, 2;
    $sets{$key} = $value;
  }
}

sub get_sets {
  return %sets;
}

sub new {
  my ($class, $set, $pairs) = @_;

  my $self = bless { cards => [], i => 0, pairs => $pairs }, $class;

  my @cards = map { ($_, $_) } shuffle(map { warn $_; basename $_, ".jpg" } glob "sets/$set/*.jpg");

  die "not enough cards" if scalar @cards < $pairs*2;

  for(1..$pairs*2) {
    push @{ $self->{cards} }, Game::Card->new($set, shift @cards);
  }

  return $self;
}

sub get_set {
  return $_[0]->{set};
}

sub get_cards {
  return shuffle(@{ $_[0]->{cards} });
}

1;

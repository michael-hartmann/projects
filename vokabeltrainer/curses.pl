#!/usr/bin/perl

use warnings;
use strict;
use utf8;

use Curses; # damn it!
use Getopt::Long;
use List::Util qw(shuffle);
use Pod::Usage;
use YAML::Syck qw(LoadFile DumpFile);

use constant {
  LANGUAGE     => "Latein",
  MISTAKE_UNIT => "Fehlerkasten",
};

our $tidy_up;
$SIG{INT} =  sub { if($tidy_up) { endwin(); }; exit 1; };

GetOptions(
  "language=s" => \(my $language = LANGUAGE),
  "shuffle!"   => \(my $shuffle = 1),
  "help"       => sub { pod2usage(0) },
) or pod2usage(1);

pod2usage(1) unless @ARGV;

# vocabulary
$YAML::Syck::ImplicitUnicode = 1;
my $vocabulary = LoadFile("vocabulary.yaml");
my @vocables;

foreach my $chapter (@ARGV) {
  push @vocables, @{ $vocabulary->{$language}->{$chapter} };
}

@vocables = shuffle(@vocables) if $shuffle;

my %count;
($count{total}, $count{wrong}, $count{right}) = (scalar @vocables, 0, 0);

{
  local $tidy_up = 1;
  # curses
  initscr();
  cbreak();

  while(my $voc = shift @vocables) {
    clear();
    move(0, 0);
    addstr(sprintf(
      "Vokabel Nr %d von %d --> noch %d Vokabel(n) zu wiederholen",
      $count{right} + $count{wrong} + 1, $count{total}, $count{total} - $count{right} - $count{wrong}
    ));

    move(1, 0);
    addstr(sprintf(
      "%d Vokabel(n) von %d  Vokabel(n) richtig (%.2f%%)",
      $count{right}, $count{total}, 
      ($count{right} + $count{wrong} > 0) ? 100 * $count{right}/($count{right} + $count{wrong}) : 0
    ));

    move(3, 0);
    addstr("Deutsch: " . (join ", ", @{$voc->[0]}));

    move(4, 0);
    addstr(">>> ");

    refresh();

    getstr(my $answer);
    if(! check($voc, $answer)) {
      clear();
      
      move(0, 0); addstr("Falsch:  >>$answer<<");
      move(1, 0); addstr("Richtig: >>" . join( ", ", @{$voc->[1]}) . "<<");
      
      refresh;

      getch();
    }
  }

  # aufraeumen
  endwin();
}

sub check {
  my ($voc, $answer) = @_;

  foreach my $solution (@{ $voc->[1] }) {
    if($solution eq $answer) {
      $count{right}++;
      $voc->[2]->[1]++;
      return 1;
    }
  }

  $count{wrong}++;
  $voc->[2]->[2]++;

  push @{ $vocabulary->{$language}->{ "@{[MISTAKE_UNIT()]}" } }, $voc;
  return 0;
}

$YAML::Syck::SortKeys = 1;
DumpFile("vocabulary.yaml" => $vocabulary);

__END__
=head=
curses.pl --language "name_of_language" /chapters/
  --language:
    Name der Sprache, deren Kapitel man lernen will

  --help:
    gibt diesen Hilfetext aus

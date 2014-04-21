package Vocabulary::Import;

use warnings;
use strict;
use utf8;

sub new {
  return bless {};
}

sub speakit2000 {
  my ($self, $file) = @_;
  my @unit;

  unless(-R $file) {
    warn "$file does not exist or is not readable";
    return;
  }

  open my $FH, "<", $file or die "Cannot open $file for reading: $!";

  while(my $line = <$FH>) {
    next unless $line =~ m/@/;

    my $vocable;
    chomp $line;

    my @parts = split "@", $line;

    {
      my $i = 0;
      foreach my $part (@parts) {
        my @solutions;
        while($part =~ s/\[(.*?)\]// ) {
          push @solutions, $1;
        }
        $part =~ s/^\s+//g; $part =~ s/\s+$//g;
        push @solutions, $part if $part;

        push @{ $vocable->[$i] }, @solutions;

        $i++;
      }
    
    }
    push @unit, $vocable;
  }
  
  close $FH;
  
  return @unit;
}

1;

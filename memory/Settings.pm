package Settings;

use warnings;
use strict;

my $FILE = "settings.cfg";

my %settings;

open my $fh, "<", $FILE or die "Can't open $FILE: $!";

while(my $line = <$fh>) {
  next unless $line =~ /:/;
  chomp $line;
  my ($key, $value) = split /:\s*/, $line, 2;
  $settings{$key} = $value;
}

close $fh or die "Can't close $FILE: $!";

sub new {
  my $class = shift;

  return bless {}, $class;
}

sub get {
  shift;

  if(wantarray) {
    return map { $settings{$_} } @_;
  } else {
    $settings{$_[0]}
  }
}

sub set {
  my ($key, $value) = @_[1,2];

  $settings{$key} = $value;

  open my $fh, ">", $FILE or die "Can't open $FILE: $!";

  while(my($key, $value) = each %settings) {
    print $fh "$key: $value\n";
  }

  close $fh or die "Can't close $FILE: $!";

  return $value;
}

1;

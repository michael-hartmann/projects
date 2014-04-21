package Log;

use warnings;
use strict;

use base "Exporter";
our @EXPORT = "info";

# Prettyprinting
sub info ($) {
  return unless $::settings->get(general => "logging");

  chomp(my $msg = shift);
  my ($package, $filename, $line) = caller;
  
  local $_;
  foreach (split /\n/, $msg) {
    #printf STDERR "[\033[31;1m%s\033[0m] \033[34;1m%s\033[0m: %s\n",
    printf STDERR "[%s] %s (%s Zeile %d)\n",
      $package,
      $_,
      $filename, $line;
  }
}


1;

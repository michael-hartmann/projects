package Settings;

use utf8;
use warnings;
use strict;

use List::Util "shuffle";

BEGIN {
  eval {
    require YAML::Syck and import YAML::Syck qw< LoadFile DumpFile >;
  };

  if($@) {
    require YAML;
    import YAML qw< LoadFile DumpFile >;
  }
}


sub new {
  use constant FILE => "settings.yaml";
  
  if(-e FILE) {
    return bless LoadFile(FILE);
  } else {
    return bless {};
  }
}

sub set {
  my ($self, $section, $key, $value) = @_;

  $self->{$section}->{$key} = $value;

  DumpFile(FILE, $self);
}

sub get {
  my ($self, $section, $key) = @_;

  return $self->{$section}->{$key} || undef;
}

1;

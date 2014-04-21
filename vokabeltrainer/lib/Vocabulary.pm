package Vocabulary;

use strict;
use utf8;
use warnings;

use Compress::Bzip2;
use Fcntl qw<:DEFAULT :flock>;
use File::Basename;
use List::Util "shuffle";

use Log;

BEGIN {
  eval { 
    require YAML::Syck and import YAML::Syck qw< LoadFile Dump >;
  };

  if($@) {
    print STDERR "Verwende YAML anstatt YAML::Syck.\n";
    print STDERR "Installieren Sie für (viel) bessere Performance YAML::Syck auf ihrem Rechner.\n";
    require YAML;
    import YAML qw< LoadFile Dump >;
  }
}

use constant FILE => "vocabulary.yaml";

sub new {
  my $self;
  info "lade Vokabeln...";
  
  if(-e FILE) {
    $self = bless LoadFile(FILE);
  } else {
    $self = bless {};
  }
  
  my $unit = $::settings->get(general => "mistake_unit");
  foreach my $language (keys %$self) {
    unless(exists $self->{$language}->{$unit}) {
      info "erstelle Fehlerkasten fuer \"$language\"";
      $self->{$language}->{$unit} = undef;
    }
  }
  
  return $self;
}

sub test {
  my ($self, $language, @units) = @_;
  
  return unless $language and defined $self->{$language};
  return unless @units and scalar @units;

  my @vocs;
  foreach my $unit (@units) {
    next unless defined $self->{$language}->{$unit};;
  
    for (my $i = 0; $i < scalar @{ $self->{$language}->{$unit} }; $i++) {
      push @vocs, [ $language, $unit, $i];
    }
  }
  
  @vocs = shuffle @vocs if $::settings->get(test => "shuffle");

  return unless scalar @vocs;

  return bless 
    {
      vocables   => [ @vocs ],
      languages  => [ $::settings->get(test => "reverse") 
                       ? ($language => $::settings->get(language => "native"))
                       : ($::settings->get(language => "native") => $language) ],
      reverse    => $::settings->get(test => "reverse") ? 1 : 0,
      tests      => $language,
      start      => scalar time,
      correct    => 0,
      incorrect  => 0,
    }, "Vocabulary::Test";
}

sub save {
  my ($self, $file) = @_;

  $file = $file || FILE; 
  my $pid = fork;

  if($pid == 0) {
    info "Speichere Vokabeln in Datei \"$file\"";

    sysopen(my $FH, $file, O_RDWR|O_CREAT) or die "Konnte Vokabeldatei nicht oeffnen: $!";
    flock($FH, LOCK_EX)                    or die "Konnte keinen exklusiven Lock bekommen: $!";
    truncate($FH, 0)                       or die "Konnte Vokabeldatei nicht abschneiden: $!";
    print $FH Dump($self)                  or die "Konnte nicht in Vokabeldatei schreiben: $!";
    close $FH                              or die "Konnte Vokabeldatei nicht schliessen: $!";
  };
}

sub get_languages {
  my $self = shift;
  my @languages = keys %{$self};

  if(wantarray) {
    return sort @languages;
  } else {
    return scalar @languages;
  }
}

sub rename_language {
  my ($self, $old, $new) = @_;
  
  return unless defined $self->{$old};

  $self->{$new} = $self->{$old};
  return unless $self->delete_language($old);

  $::gui{left}->update;

  return 1;
}

sub delete_language {
  my ($self, $language) = @_;

  return unless $language and defined $self->{$language};

  delete $self->{$language};

  $::gui{left}->update;
  
  return 1;
}

sub get_units {
  my ($self, $language) = @_;
  
  my $get = sub {
    return (keys %{ $self->{$_[0]} });
  };

  my @units;
  
  if($language) {
    return unless defined $self->{$language};
    @units = $get->($language);
  } else {
    foreach my $language (keys %$self) {
      push @units, $get->($language);
    }
  }
  
  if(wantarray) {
    return sort @units;
  } else {
    return scalar @units;
  }
}

sub count_vocables {
  my ($self, $language, @units) = @_;

  # sub-ref counts vocables in a unit
  my $count = sub {
    my ($language, $unit) = @_;

    # mabe this unit is still empty, so it is not yet an array-ref
    return 0 unless ref $self->{$language}->{$unit} eq "ARRAY";
    return scalar @{ $self->{$language}->{$unit} };
  };
  
  if($language and !@units) {
    @units = keys %{$self->{$language}}
  }

  if($language) {
    # count vocables for all units in $language
    my $no = 0;
    foreach my $unit (@units) {
      $no += $count->($language => $unit);
    }
    return $no;
  } else {
    # count all vocables in all languages and in all units
    my $no = 0;
    
    foreach my $language (keys %{$self}) {
      foreach my $unit (keys %{ $self->{$language} }) {
        $no += $count->($language => $unit);
      }
    }
    return $no;
  }
}

sub add_language {
  my ($self, $name) = @_;

  return if $self->{$name};

  $self->{$name} = {};
  $::gui{left}->update;

  return 1;
}

sub add_vocable {
  my ($self, $language, $unit, $vocable) = @_;

  return unless ref $vocable eq "ARRAY";

  push @{ $self->{$language}->{$unit} }, $vocable;

  return 1;
}

sub remove_vocable {
  my ($self, $language, $unit, $i) = @_;

  return unless ref $self->{$language}->{$unit}->[$i] eq "ARRAY";

  splice @{ $self->{$language}->{$unit} }, $i, 1;

  return 1;
}

1;

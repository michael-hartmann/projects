package Vocabulary::Test;

use utf8;
use warnings;
use strict;

use Log;

sub get_vocable {
  my ($self, $j) = @_;
  $j = 0 unless($j and ($j == 1 or $j == 2));
  
  return unless scalar @{$self->{vocables}};
  my ($language, $unit, $i) = @{ @{$self->{vocables}}[0] }; 
  return @{ $::voc->{$language}->{$unit}->[$i]->[$j] };
}

sub correct {
  my $self = shift;
  return $self->{correct}
}

sub incorrect {
  my $self = shift;
  return $self->{incorrect};
}

sub average {
  my $self = shift;

  # avoid division by zero
  return 100 unless
    my $total = $self->{correct} + $self->{incorrect};

  my $average =  $self->{correct} / $total;
  return sprintf "%.0f", $average * 100;
}

sub total {
  my $self = shift;
  return $self->{correct} + $self->{incorrect} + scalar @{ $self->{vocables} };
}

sub check {
  my ($self, $answer) = @_;
 
  my ($language, $unit, $i) = @{ shift @{$self->{vocables}} };
  my $vocable = $::voc->{$language}->{$unit}->[$i];

  foreach my $solution (@{ $vocable->[1] }) {
    if($solution eq $answer) {
      if($unit eq $::settings->get(general => "mistake_unit")) {
        info "entferne Vokabel aus Fehlerkasten";
        $::voc->remove_vocable($language, $unit, $i); 
      } else {
        $vocable->[2]->[0]++;
        $self->{correct}++;
      }
      return 1;
    }
  } 

  $vocable->[2]->[1]++;
  $self->{incorrect}++;

  $::voc->add_vocable($self->{tests}, $::settings->get(general => "mistake_unit"), $vocable);
  return 0;
}

sub get_languages {
  my $self = shift;
  return @{ $self->{languages} };
}

sub get_chars {
  my $self = shift;
  
  if(my $i = $::settings->get(test => "show_chars")) {
    return substr(($self->get_vocable(1))[0], 0, $i)
  } else {
    return "";
  }
}

1;

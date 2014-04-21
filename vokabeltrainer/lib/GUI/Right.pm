package GUI::Right;

use utf8;
use warnings;
use strict;

use Glib qw< TRUE FALSE >;
use Gtk2 qw< -init      >;

sub new {
  my $self = bless {};
  
  $self->{vbox} = Gtk2::VBox->new(FALSE, 5);

  # statistics 
  {
    $self->{frame_top} = Gtk2::Frame->new("Übersicht");
    $self->{frame_top}->set_border_width(5);
    
    $self->{vbox}->pack_start($self->{frame_top}, TRUE, TRUE, 0);
  }

  {
    $self->{frame_bottom} = Gtk2::Frame->new("Lektion");
    $self->{frame_bottom}->set_border_width(5);

    $self->{button} = Gtk2::Button->new("Abfrage starten");
    $self->{button}->set_image(Gtk2::Image->new_from_stock("quiz", "button"));
    $self->{button}->signal_connect(clicked => sub {
      my $uimanager = $::gui{top}->get_uimanager || return;
      $uimanager->get_action("/MenuBar/VocablesMenu/test_unit")->activate;
    });

    $self->{frame_bottom}->add($self->{button});
    $self->{vbox}->pack_start($self->{frame_bottom}, FALSE, FALSE, 5);
  }
  
  return $self;
}

sub get_vbox {
  my $self = shift;
  
  return $self->{vbox};
}

sub update {
  my $self = shift;
  my ($language, @units) = @_;

  my $row = 0;

  $self->{table}->destroy if $self->{table};

  $self->{table} = Gtk2::Table->new(3, 2, FALSE);
  
  $self->{table}->attach_defaults(
    Gtk2::Label->new("Sprache"),
    0, 1, $row, $row+1
  );
  $self->{table}->attach_defaults(
    Gtk2::Label->new($language),
    1, 2, $row, $row+1
  ); 
  
  $row++;

  # unit
  if(@units) {
    $self->{table}->attach_defaults(
      Gtk2::Label->new("Lektionen"),
      0, 1, $row, $row+1
    );
    $self->{table}->attach_defaults(
      Gtk2::Label->new(join ", ", @units),
      1, 2, $row, $row+1
    );
  }

  $row++;
  
  # vocables
  $self->{table}->attach_defaults(
    Gtk2::Label->new("Vokabeln"),
    0, 1, $row, $row+1
  );
  
  # number of vocables
  $self->{table}->attach_defaults(
    Gtk2::Label->new($::voc->count_vocables($language => @units)),
    1, 2, $row, $row+1
  );

  $self->{table}->show_all;
  $self->{frame_top}->add($self->{table});
  
  return 1;
}

1;

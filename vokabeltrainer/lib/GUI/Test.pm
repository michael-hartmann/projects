package GUI::Test;

use utf8;
use warnings;
use strict;
use Vocabulary;
use Vocabulary::Test;

use GUI::Test::Info;
use GUI::Test::Statistics;
use GUI::Test::Incorrect;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};
shift;
  # avoid errors when user try to test a unit that has no vocables yet
  $self->{test} = $::voc->test(@_) || return;
  
  $self->{window} = Gtk2::Window->new;
  $self->{window}->set_default_icon_name("quiz");
  $self->{window}->set_modal(TRUE);
  $self->{window}->set_transient_for($::gui{window}->get_window);
  $self->{window}->set_skip_taskbar_hint(TRUE);
  $self->{window}->set_resizable(FALSE);
  $self->{window}->set_title("Vokabeln abfragen");

  # main vbox
  $self->{vbox} = Gtk2::VBox->new(FALSE, 0);
  $self->{window}->add($self->{vbox});
  
  # frame with information, top
  $self->{info} = GUI::Test::Info->new;
  $self->{vbox}->pack_start($self->{info}->get_frame, TRUE, TRUE, 5);
  
  # table with entries (check vocables), middle
  {
    $self->{frame} = Gtk2::Frame->new("Vokabeln abfragen");
    $self->{frame}->set_border_width(5);
    $self->{vbox}->pack_start($self->{frame}, TRUE, TRUE, 5);

    # vbox for check and statistics frame
    $self->{vbox2} = Gtk2::VBox->new(FALSE, 5);
    $self->{frame}->add($self->{vbox2});
    
    # own/foreign language
    {
      # table with entries
      $self->{table} = Gtk2::Table->new(2, 2, FALSE);
      $self->{table}->set_border_width(5);
      $self->{table}->set_col_spacings(5);
      $self->{vbox2}->pack_start($self->{table}, TRUE, TRUE, 5);
      
      $self->{table}->attach_defaults(
        Gtk2::Label->new(($self->{test}->get_languages)[0] . ":"),
        0, 1, 0, 1
      );

      $self->{entry}->[0] = Gtk2::Entry->new;
      $self->{entry}->[0]->set_width_chars(60);
      $self->{entry}->[0]->set_editable(FALSE);
      $self->{table}->attach_defaults($self->{entry}->[0], 1, 2, 0, 1);

      $self->{table}->attach_defaults(
        Gtk2::Label->new(($self->{test}->get_languages)[1] . ":"),
        0, 1, 1, 2
      );

      $self->{entry}->[1] = Gtk2::Entry->new;
      $self->{entry}->[1]->set_activates_default(TRUE);
      $self->{table}->attach_defaults(
        $self->{entry}->[1],
        1, 2, 1, 2
      );
    }

    # statistic
    $self->{statistics} = GUI::Test::Statistics->new;
    $self->{vbox2}->pack_start($self->{statistics}->get_frame, FALSE, FALSE, 5);
  }

  # bottom (buttons)
  {
    $self->{hbox} = Gtk2::HBox->new(FALSE, 0);
    $self->{hbox}->set_border_width(5);
    $self->{vbox}->pack_end($self->{hbox}, FALSE, FALSE, 0);

    $self->{button_check} = Gtk2::Button->new("Überprüfen");
    $self->{button_check}->set_image(Gtk2::Image->new_from_stock("ok", "button"));
    $self->{hbox}->pack_end($self->{button_check}, FALSE, FALSE, 0);
    $self->{button_check}->can_default(TRUE);
    $self->{button_check}->grab_default;
    $self->{button_check}->signal_connect(
      clicked => sub {
        my ($native, $correct) = (
          [ $self->{test}->get_vocable(0) ], [ $self->{test}->get_vocable(1) ]
        );
        
        if($self->{test}->check($self->{entry}->[1]->get_text)) {
          # korrekt
          # [...]
        } else {
          # inkorrekt
          GUI::Test::Incorrect->new($native, $correct, $self->{entry}->[1]->get_text);
        }
        $self->update;
      }
    );

    $self->{button_abort} = Gtk2::Button->new_from_stock("Abbrechen");
    $self->{button_abort}->set_image(Gtk2::Image->new_from_stock("cancel", "button"));
    $self->{hbox}->pack_end($self->{button_abort}, FALSE, FALSE, 0);
    $self->{button_abort}->signal_connect(clicked => sub { $self->destroy; });
  }

  # update enries and statistics
  $self->update;
  
  $self->{window}->show_all;
  $self->{window}->present;
  return $self;
}
  
sub update {
  my $self = shift;
  my $test = $self->{test};

  my @vocable = $test->get_vocable;
  
  # there is at least one unanswerd vocables left
  if(scalar @vocable) {
    $self->{entry}->[0]->set_text(join ", ", @vocable);
    $self->{entry}->[1]->set_text($test->get_chars);
    $self->{entry}->[1]->grab_focus;
    
    $self->{statistics}->set_markup(
      0 => sprintf(
        "Nr. %d von %d",
        $test->correct + $test->incorrect + 1, $test->total
      )
    );
    $self->{statistics}->set_markup(
      1 => "<span foreground=\"#008000\">".$test->correct."</span>"
    );
    $self->{statistics}->set_markup(
      2 => "<span foreground=\"red\">".$test->incorrect."</span>"
    );
    $self->{statistics}->set_markup(
      3 => sprintf "%d%% richtig", $test->average
    );
  } else {
    $self->finished;
  }
}

sub finished {
  my $self = shift;
  $self->destroy;
}

sub destroy {
  my $self = shift;
  
  $self->{window}->destroy;
}

1;

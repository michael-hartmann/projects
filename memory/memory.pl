#!/usr/bin/perl

use warnings;
use strict;
use utf8;

BEGIN {
  use FindBin;

  use lib $FindBin::Bin;

  eval "use Win32::Sound" if $^O eq "MSWin32";
}

use Gtk2 qw< -init      >;
use Glib qw< TRUE FALSE >;

use constant RATIO => 9/16;
use File::Basename;

use Settings;
use Game::Card;
use Game::Cards;

my $settings = Settings->new;
my %stats;

my %gui;
my $window = $gui{window} = Gtk2::Window->new;
$window->signal_connect(delete_event => \&quit);
$window->set_border_width(0);
$window->set_title("Memory");

my $vbox = $gui{vbox} = Gtk2::VBox->new(FALSE, 5);
$window->add($vbox);

# menu
{
  my $menu = Gtk2::Menu->new;
  
  my $new = Gtk2::ImageMenuItem->new_from_stock("gtk-new");
  $new->signal_connect(activate => \&start); 
  $menu->append($new);

  $menu->append(Gtk2::SeparatorMenuItem->new);
  
  my $cover = Gtk2::MenuItem->new("Deckblatt");
  $cover->signal_connect(activate => sub {
    my $dialog = Gtk2::Dialog->new("Deckblatt",
      $window, [qw/modal destroy-with-parent/]
    );
    $dialog->signal_connect(response => sub { $dialog->destroy });

    my @covers = glob "covers/*.jpg";

    my $rows = ceil(sqrt(  RATIO * scalar @covers));
    my $cols = ceil(sqrt(1/RATIO * scalar @covers));

    my $table  = Gtk2::Table->new($rows, $cols, FALSE);
    $dialog->vbox->add($table);

    my $i = 0;
    foreach my $cover (@covers) {
      my $col =     $i   % $cols;
      my $row = int($i++ / $cols);

      my $button = Gtk2::Button->new;
      $button->set_image(Gtk2::Image->new_from_file($cover));
      $button->signal_connect(clicked => sub {
        $dialog->destroy;
        $settings->set(cover => basename($cover, ".jpg"));
        start();
      });
      $table->attach_defaults($button, $col, $col+1, $row, $row+1);
    }

    $dialog->show_all; $dialog->run;
  });
  $menu->append($cover);
  
  my $set   = Gtk2::MenuItem->new("Kartenset");
  $set->signal_connect(activate => sub {
    my $dialog = Gtk2::Dialog->new("Kartenset",
      $window, [qw/modal destroy-with-parent/],
      "gtk-ok"     => 1,
      "gtk-cancel" => 0
    );

    my %sets = Game::Cards->get_sets;
    my $box  = Gtk2::ComboBox->new_text;
    my $aset = $settings->get("set");
    
    my $i = 0;
    foreach my $key (sort keys %sets) {
      my $value = $sets{$key};
      $box->append_text("$key: $value");
      $box->set_active($i) if $aset eq $key;
      $i++;
    }

    $dialog->vbox->add($box);

    $dialog->signal_connect(response => sub { 
      my $active = $box->get_active_text;
      $dialog->destroy;
      if($_[1]) {
        my ($set) = split /:/, $active, 2;
        $settings->set(set => $set);
        start();
      }
    });
    $dialog->show_all;
    $dialog->run;
  });
  $menu->append($set);

  my $pairs = Gtk2::MenuItem->new("Anzahl der Paare");
  $pairs->signal_connect(activate => sub {
    my $dialog = Gtk2::Dialog->new("Anzahl der Paare",
      $window, [qw/modal destroy-with-parent/],
      "gtk-ok"     => 1,
      "gtk-cancel" => 0
    );

    my $hbox = Gtk2::HBox->new(FALSE, 5);
    $dialog->vbox->add($hbox);
    my $label = Gtk2::Label->new("Anzahl der Paare:");
    my $spin  = Gtk2::SpinButton->new_with_range(2, 32, 1);
    $spin->set_value($settings->get("pairs"));

    $hbox->pack_start($_, FALSE, FALSE, 5) for ($label, $spin);

    $dialog->show_all;
    my $resp = $dialog->run; $dialog->destroy;
    if($resp) {
      $settings->set(pairs => $spin->get_value);
      start();
    }
  });
  $menu->append($pairs);

  my $sound = Gtk2::CheckMenuItem->new("Ton");
  $sound->set_active($settings->get("sound"));
  $sound->signal_connect(toggled => sub {
    $settings->set(sound => $sound->get_active);
  });
  $menu->append($sound);

  $menu->append(Gtk2::SeparatorMenuItem->new);

  my $quit = Gtk2::ImageMenuItem->new_from_stock("gtk-quit");
  $quit->signal_connect(activate => \&quit);
  $menu->append($quit);

  my $bar  = Gtk2::MenuBar->new;
  my $game = Gtk2::MenuItem->new('_Spiel');
  $game->set_submenu($menu);
  $bar->append($game);

  $vbox->pack_start($bar, FALSE, FALSE, 0);
}

start();
$window->show_all;
Gtk2->main;

sub ceil {
  my $f = shift;
  return $f if $f == int $f;
  return int($f+1);
}

sub start {
  my ($set, $pairs) = $settings->get(qw< set pairs >);

  undef %stats;
  @stats{qw< started clicks pairs >} = (time, 0, $pairs);

  my $rows = ceil(sqrt(  RATIO * 2 * $pairs));
  my $cols = ceil(sqrt(1/RATIO * 2 * $pairs));

  $gui{table}->destroy if $gui{table};
  my $table = $gui{table} = Gtk2::Table->new($rows, $cols, FALSE);
  $vbox->pack_start($table, FALSE, FALSE, 5);

  my $game  = Game::Cards->new($set, $pairs);
  my @cards = $game->get_cards;

  my $i = 0;

  my @selected = ();
  foreach my $card (@cards) {
    my $col =     $i   % $cols;
    my $row = int($i++ / $cols);

    my $button = Gtk2::Button->new;
    $button->set_relief("none");
    $button->set_image($card->hide);

    my $callback = sub {
      $stats{clicks}++;

      if($card->shown) {
        $button->set_image($card->hide);
        if($selected[0]->[0]->get_id eq $card->get_id) {
          shift @selected;
        } else {
          pop @selected
        }
      } else {
        if(@selected == 2) {
          for my $ref (@selected) {
            my ($card, $button) = @$ref; 
            $button->set_image($card->hide);
	        }
          undef @selected;
        }

        push @selected, [ $card, $button ];

        if(@selected == 1) {
          $button->set_image($card->unhide);
        } elsif(@selected == 2) {
          $button->set_image($card->unhide);
          
          if($card->compare($selected[0]->[0])) {
            $_->[1]->set_sensitive(FALSE) for @selected;
            undef @selected;
            finished() unless --$pairs;
            return play("match");
          }
        }
      }

      play("click");
    };

    $button->signal_connect(clicked => $callback);

    $table->attach_defaults($button, $col, $col+1, $row, $row+1);
  }

  $table->show_all;
}

sub sec2human {
  my $min = int($_[0] / 60);
  my $sec =     $_[0] % 60;

  $min = "0$min" if length $min == 1;
  $sec = "0$sec" if length $sec == 1;

  return ($min, $sec);
}

sub finished {
  play("success");

  my $dialog = Gtk2::MessageDialog->new($window,
    "destroy-with-parent", "info", "yes-no",
    sprintf "Sie haben %s Zeit und %d Versuche gebraucht, um alle %d Paare zu finden.\n\n"
          . "Wollen Sie ein neues Spiel beginnen?",
      join(":", sec2human(time - $stats{started})), $stats{clicks}/2, $stats{pairs}
  );
  my $resp = $dialog->run; $dialog->destroy;
  start() if $resp eq "yes";
}

sub play {
  return unless $^O eq "MSWin32";
  return unless $settings->get("sound");

  Win32::Sound::Play("sounds/$_[0].wav", $_[1] =~ /async/i ? () : Win32::Sound::SND_ASYNC());
}

sub quit {
  Gtk2->main_quit;

  play("bye", "SYNC");
}

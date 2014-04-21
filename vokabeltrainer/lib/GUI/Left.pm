package GUI::Left;

use utf8;
use warnings;
use strict;

use Gtk2;
use Glib qw<TRUE FALSE>;

sub new {
  my $self = bless {};

  $self->{frame} = Gtk2::Frame->new("Lektionen");
  $self->{frame}->set_border_width(5);
  
  $self->{sw} = Gtk2::ScrolledWindow->new(undef, undef);
  $self->{sw}->set_policy("automatic", "automatic");
  $self->{sw}->set_size_request(0, 200);
  $self->{sw}->set_border_width(5);
  $self->{frame}->add($self->{sw});

  # treeview
  $self->{treestore} = Gtk2::TreeStore->new("Glib::String");
  $self->update;

  $self->{treeview} = Gtk2::TreeView->new($self->{treestore});
  $self->{treeview}->get_selection->set_mode("extended");
  $self->{treeview}->set_rules_hint(TRUE);       # improve readability
  $self->{treeview}->set_headers_visible(FALSE); # no header
  $self->{sw}->add($self->{treeview});
  
  $self->{treecolumn} = Gtk2::TreeViewColumn->new;
  my $renderer = Gtk2::CellRendererText->new;
  $self->{treecolumn}->pack_start($renderer, FALSE);
  $self->{treecolumn}->add_attribute($renderer, text => 0);

  $self->{treeview}->append_column($self->{treecolumn});

  $self->{treeview}->get_selection->set_select_function(
    sub { $self->select_function(@_) }
  );

  $self->{treeview}->signal_connect(event_after => sub {
    my ($treeview, $event) = @_;
    
    return 
      unless ($event->type eq "button-release" or $event->type eq "key-release");

    $::gui{right}->update($self->get_selected)
      if ($self->get_selected)[0];

    return 1;
  });

  return bless $self;
}

sub get_frame {
  my $self = shift;
  
  return $self->{frame};
}

sub get_selected {
  my $self = shift;
  
  my $treeview = $self->{treeview};
  
  my ($language, @units);
  
  $treeview->get_selection->selected_foreach(sub {
    my ($treestore, $treepath, $treeiter) = @_;

    if(!$treeview->get_model->iter_parent($treeiter) and !$language) {
      $language = $treeview->get_model->get_value($treeiter);
      return;
    }

    $language = $treeview->get_model->get_value($treeview->get_model->iter_parent($treeiter))
      unless $language;
    
    push @units, $treeview->get_model->get_value($treeiter);
  });
 
  return ($language, @units);
}

sub update {
  my $self = shift;

  $self->{treestore}->clear;

  foreach my $language ($::voc->get_languages) {
    my $iter = $self->{treestore}->append(undef);
    $self->{treestore}->set($iter, 0 => $language);

    foreach my $unit ($::voc->get_units($language)) {
      my $iter_child = $self->{treestore}->append($iter);
      $self->{treestore}->set($iter_child, 0 => $unit);
    }
  }

  return TRUE;
}

sub select_function {
  my ($self, $treeselection, $treestore, $treepath, $unselected) = @_;
 
  # don't bother when user unselects unit/language
  return TRUE if $unselected;
  
  # get selected language from treepath
  my $get_language = sub {
    my $treepath = shift;
    
    # iter of selected row (either language or unit)
    my $iter = $self->{treeview}->get_model->get_iter($treepath);
    
    if(my $parent_iter = $self->{treeview}->get_model->iter_parent($iter)) {
      # parent exists - so parent is language
      return $self->{treeview}->get_model->get_value($parent_iter);
    } else {
      # no parent - so iter is already language
      return $self->{treeview}->get_model->get_value($iter);
    }
  };

  my $language = $get_language->($treepath);
  
  # unselect every selected item not belonging to $language
  $treeselection->selected_foreach(sub {
    my ($treestore, $treepath, $treeiter) = @_;

    $treeselection->unselect_iter($treeiter)
      if $get_language->($treepath) ne $language;
  });

  return TRUE;
}

1;

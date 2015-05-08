
use strict;

# Creates a new function definition given (type, implementation).
sub function
{
  my ($type, $impl) = @_;

  return bless {type => $type, impl => $impl}, 'function';
}

package function;
use Data::Dumper;
use Carp qw(confess);

sub type
{
  my ($f, $arg) = @_;

  return $f->{type};
}

sub compile
{
  my ($f) = @_;

  my $type = $f->{type};

  if (ref $type eq 'type')
  {
    if (ref $f->{impl} eq 'CODE')
    {
      confess "Code reference not expected for a value of type ".$type->name;
    }
  }
  elsif (ref $type eq 'arrow')
  {
    if (ref $f->{impl} ne 'CODE')
    {
      confess "Expected a code reference for a function type ".$type->name;
    }
  }
  else { confess "Illegal type $type"; }

  return $f->{impl};
}

1;

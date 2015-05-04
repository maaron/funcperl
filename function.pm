
use strict;

# Creates a new function definition given (type, implementation).
sub function
{
  my ($type, $impl) = @_;

  if (ref $type ne 'type' && ref $type ne 'arrow') { confess "Illegal type $type"; }

  return bless {type => $type, impl => $impl}, 'function';
}

package function;

sub typecheck
{
  my ($f) = @_;
  return $f->{type};
}

sub compile
{
  my ($f) = @_;

  return return $f->{impl};
}

1;

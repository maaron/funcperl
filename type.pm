
use Carp qw(confess);
use strict;

# Creates a new singular type
sub type
{
  my ($name) = @_;
  return bless \$name, 'type';
}

# Creates a new function type of the form 'a -> b'
sub arrow
{
  my ($left, $right) = @_;
  return bless {left => $left, right => $right}, 'arrow';
}

package type;
use Carp qw(confess);
use strict;

sub apply
{
  confess "Singular types do not admit application";
}

sub equals
{
  my ($type, $rhs) = @_;

  if (ref $rhs eq ref $type)
  {
    if ($$rhs ne $$type)
    {
      confess "Type mismatch: $$type != $$rhs";
    }
  }
  else
  {
    confess "Type type mismatch: $type != $rhs";
  }
}

# This package encapsulates type constructions of the form "a -> b"
package arrow;
use Carp qw(confess);
use strict;

sub apply
{
  my ($arr, $argtype) = @_;

  $arr->{left}->equals($argtype);
  return $arr->{right};
}

sub equals
{
  my ($type, $rhs) = @_;

  if (ref $rhs eq ref $type)
  {
    $type->{left}->equals($rhs->{left});
    $type->{right}->equals($rhs->{right});
  }
  else
  {
    confess "Type type mismatch: $type != $rhs";
  }
}

1;


use Carp qw(confess);
use strict;

my %types;

# Creates a new singular type
sub type
{
  my ($name) = @_;
  my $type = bless \$name, 'type';
  return $type;
}

# Creates a new function type of the form 'a -> b'
sub arrow
{
  my $left = shift @_;
  my $right;

  if (@_ == 0)
  {
    confess "Wrong number of arguments";
  }
  elsif (@_ == 1)
  {
    $right = shift @_;
  }
  else
  {
    $right = arrow(@_);
  }

  return bless {left => $left, right => $right}, 'arrow';
}

package type;
use Carp qw(confess);
use strict;

sub name
{
  my ($t) = @_;
  return $$t;
}

sub apply
{
  confess "Singular types do not admit application";
}

sub equals
{
  my ($type, $rhs) = @_;

  return 
    (ref $rhs eq ref $type) &&
    ($$rhs eq $$type);
}

# This package encapsulates type constructions of the form "a -> b"
package arrow;
use Carp qw(confess);
use strict;

sub name
{
  my ($a) = @_;
  my $lname = $a->{left}->name;
  my $rname = $a->{right}->name;

  return "($lname -> $rname)";
}

sub apply
{
  my ($arr, $argtype) = @_;

  if (!$arr->{left}->equals($argtype))
  {
    confess "Cannot apply ".$argtype->name." to function of type ".$arr->name;
  }

  return $arr->{right};
}

sub equals
{
  my ($type, $rhs) = @_;

  return
    (ref $rhs eq ref $type) &&
    $type->{left}->equals($rhs->{left}) &&
    $type->{right}->equals($rhs->{right});
}

1;

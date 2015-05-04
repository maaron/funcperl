
use strict;

sub application
{
  my ($lhs, $rhs) = @_;
  return bless {left => $lhs, right => $rhs}, 'application';
}

package application;

sub typecheck
{
  my ($a) = @_;

  my $lhs = $a->{left};
  my $rhs = $a->{right};

  my $ltype = $lhs->typecheck;
  my $rtype = $rhs->typecheck;
  return $ltype->apply($rtype);
}

sub compile
{
  my ($a) = @_;

  $a->typecheck;

  my $left = $a->{left};
  my $right = $a->{right};
  my $lcode = $left->compile;
  my $rcode = $right->compile;

  if (ref $left eq 'application')
  {
    if (ref $right eq 'application')
    {
      return sub {
        $lcode->()->($rcode->());
      };
    }
    else
    {
      return sub {
        $lcode->()->($rcode);
      };
    }
  }
  else
  {
    if (ref $right eq 'application')
    {
      return sub {
        $lcode->($rcode->());
      };
    }
    else
    {
      return sub {
        $lcode->($rcode);
      };
    }
  }
}

1;

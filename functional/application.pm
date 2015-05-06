
use strict;

sub application
{
  if (@_ == 1)
  {
    confess "Wrong number of arguments";
  }

  my $lhs = shift @_;
  my $rhs = shift @_;

  my $app = bless {left => $lhs, right => $rhs}, 'application';

  if (@_ > 0)
  {
    return application($app, @_);
  }
  else
  {
    return $app;
  }
}

package application;

sub type
{
  my ($a) = @_;

  my $lhs = $a->{left};
  my $rhs = $a->{right};

  my $ltype = $lhs->type;
  my $rtype = $rhs->type;
  return $ltype->apply($rtype);
}

sub compile
{
  my ($a) = @_;

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

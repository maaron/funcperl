
use Carp;
use Data::Dumper;
$Data::Dumper::Indent = 1;

use functional;
use function;
use type;
use application;

use strict;

sub run
{
  my ($e, @args) = @_;
  $e->compile->(@args);
}

my $scalar = type('scalar');
my $unary = arrow($scalar, $scalar);
my $one = function($scalar, 1);
my $two = function($scalar, 2);
my $three = function($scalar, 3);
my $add_one = function($unary, sub { return $_[0] + 1; });

my $app = application($add_one,
            application($add_one, $one));

my $twice = function(
  arrow($unary, $unary),
  sub { 
    my ($f) = @_;
    return sub { 
      $f->($f->($_[0])); } });

my $twice_add_one = application($twice, $add_one);

my $app_code = $app->compile;
print "app = ".$app_code->()."\n";

my $add_one_code = $add_one->compile;
print "add_one 2 = ".$add_one_code->(2)."\n";

my $twice_code = $twice->compile;
print "(twice add_one) 3 = ".$twice_code->($add_one_code)->(3)."\n";

my $twice_add_one_code = $twice_add_one->compile;
print $twice_add_one_code->()->(4)."\n";

$app = application($twice_add_one, $two)->compile;
print "twice_add_one 2 = ".$app->()."\n";

# Binary function test
my $plus = curried(
  arrow($scalar, $scalar, $scalar),
  sub {
    my ($a, $b) = @_;
    return $a + $b;
  });

print "(plus 2 3) = ".run(application(application($plus, $two), $three))."\n";

# Conditional evaluation test
my $empty = type('empty');

sub nullary
{
  my ($return_type) = @_;
  return arrow($empty, $return_type);
}

my $nullary_scalar = nullary($scalar);

my $bool = type('bool');
my $true = function($bool, 1);
my $false = function($bool, 0);

# This function makes functions with more than 1 argument easier to write.  The
# curried_impl can be written as though all the arguments are passed on the
# Perl stack (in @_).  Internally, this implementation will be wrapped inside a
# chain of functions will store the arguments and return a function that calls
# the next function in the chain, terminating in the supplied curried_impl.
# Note that this cannot be used for curried implementations that return a
# function (in other words, a partially curried implementation).  The curried
# implementation is always expected to return a singular type.
sub curried
{
  my ($type, $curried_impl) = @_;

  my $curry;
  $curry = sub
  {
    my ($type) = @_;

    if (ref $type->{right} eq 'arrow')
    {
      my $next = $curry->($type->{right});
      return sub { 
        my @args = @_; 
        return sub {
          $next->(@args, @_); 
        };
      };
    }
    else { return $curried_impl; }
  };

  if (ref $type eq 'arrow')
  {
    return function($type, $curry->($type, $curried_impl));
  }
  else
  {
    confess "curried function must have a function type, not ".$type->name;
  }
}

sub cond
{
  my ($return_type) = @_;

  my $branch_type = nullary($return_type);

  return curried(
    arrow($bool, $branch_type, $branch_type, $return_type),
    sub {
      my ($cond, $then, $else) = @_;
      if ($cond) { return $then->(); }
      else { return $else->(); }
    });
}

sub constant { return function($scalar, $_[0]); }
sub nullary_constant { my ($c) = @_; return function(nullary($scalar), sub { return $c; }); }

my $print = function(
  arrow($scalar, $empty, $empty),
  sub { 
    my ($message) = @_;
    return sub { print $message."\n"; }; });

my $print_foo = application($print, constant('foo'));
my $print_bar = application($print, constant('bar'));

run($print_foo);

my $else = application(cond($empty), $false, $print_foo, $print_bar);

my $then = application(cond($empty), $true, $print_foo, $print_bar);

print "Else\n";
run($else);

print "Then\n";
run($then);

print "if 0 then 1 else 2 = ".run(application(cond($scalar), $false, 
    nullary_constant('one'), nullary_constant('two')))."\n";

print "if 1 then 1 else 2 = ".run(application(cond($scalar), $true, 
    nullary_constant('one'), nullary_constant('two')))."\n";

  

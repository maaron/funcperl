
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
my $plus = function(
  arrow($scalar, arrow($scalar, $scalar)),
  sub {
    my ($a) = @_;
    return sub {
      my ($b) = @_;
      return $a + $b;
    };
  });

print "(plus 2 3) = ".run(application(application($plus, $two), $three))."\n";

# Conditional evaluation test
my $empty = type('empty');

my $nullary = arrow($empty, $scalar);

my $bool = type('bool');
my $true = function($bool, 1);
my $false = function($bool, undef);

my $if = function(
  arrow($bool, arrow($nullary, $empty)),
  sub {
    my ($cond) = @_;
    if ($cond) { return sub { $_[0]->(); }; }
    else { return sub {}; }
  });

sub constant { return function($scalar, $_[0]); }

my $print = function(
  arrow($scalar, $nullary),
  sub { 
    my ($message) = @_;
    return sub { print $message."\n"; }; });

my $print_foo = application($print, constant('foo'));

run($print_foo);

my $noop = application(
  application($if, $false), $print_foo);

my $doop = application(
  application($if, $true), $print_foo);

print "Noop:\n";
run($noop);

print "Doop:\n";
run($doop);

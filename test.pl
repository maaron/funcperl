
use Carp;
use Data::Dumper;

use functional;
use function;
use type;
use application;

use strict;

my $scalar = type('scalar');
my $unary = arrow($scalar, $scalar);
my $one = function($scalar, 1);
my $two = function($scalar, 2);
my $add_one = function($unary, sub { return $_[0] + 1; });

my $app = application($add_one,
            application($add_one, $one));

my $twice = function(
  arrow ($unary, $unary),
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

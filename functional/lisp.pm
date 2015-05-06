package lisp;

use Data::Dumper;
use Carp qw(confess);
use strict;

# This package is used to parse lisp-style syntax into a Perl data structure.
# A list is represented in Perl as an array reference scalars and/or array
# references.

sub fail
{
  my ($data, $msg) = @_;
  confess "$msg at\n".substr($$data, pos($$data))."\n"
}

sub debug
{
  return if 1;
  my ($data, $msg) = @_;
  print "$msg\n".substr($$data, pos($$data))."\n";
}

sub end { 
  my ($data) = @_;
  debug $data, 'checking for end '.pos($$data).', '.length($$data);
  return pos($$data) >= length($$data); }

sub whitespace { ${$_[0]} =~ /\G\s*/gc; }

sub elements;
sub list;
sub element;
sub token;

sub token
{
  my ($in) = @_;

  debug $in, 'parsing token';

  $$in =~ /\G([^ \(\)]+)/gc;
  return $1;
}

sub element
{
  my ($in) = @_;

  debug $in, 'parsing element';

  whitespace $in;

  return undef if end $in;

  debug $in, 'parsing list or token';
  return (list $in or token $in);
}

sub lparen { ${$_[0]} =~ /\G\(/gc; }
sub rparen { ${$_[0]} =~ /\G\)/gc; }

sub list
{
  my ($in) = @_;

  my @list = ();

  debug $in, 'parsing list';

  whitespace $in;

  return undef if !lparen $in;

  my $elements = elements $in;

  return undef if !rparen $in;

  return $elements;
}

sub elements
{
  my ($in) = @_;

  debug $in, 'parsing elements';

  my @list;
  for (1..10)
  {
    my $e = element $in;
    if (defined $e)
    {
      push @list, $e;
    }
    else { last; }
  }
  return \@list;
}

sub parse
{
  my $in = \$_[0];

  my $list = list($in);

  whitespace $in;

  return (end $in) ? $list
    : fail $in, 'Extra characters';
}

1;

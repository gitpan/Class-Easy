#!/usr/bin/perl

use Class::Easy;

use Test::More qw(no_plan);

eval "
	\$aaa = 'bbb';
";

ok $@, "strict is turned on by Class::Easy";

use IO::Scalar;

my $str;
my $err = tie *STDERR, 'IO::Scalar', \$str;

eval "
	my \@a = (1);
	my \$aaa = \@a[0];
";

diag $str;

undef $err;
untie *STDERR;

ok $str; #, "warnings is turned on by Class::Easy; warning is: $err";

# ok ! $^W, "warnings is not turned on globally";

1;
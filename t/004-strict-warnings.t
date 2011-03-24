#!/usr/bin/perl

use Class::Easy;

use Test::More qw(no_plan);

eval "
	\$aaa = 'bbb';
";

ok $@, "strict is turned on by Class::Easy";

use Class::Easy::Log::Tie;

my $str;
my $err = tie *STDERR => 'Class::Easy::Log::Tie', \$str;

eval "
	my \@a = (1);
	my \$aaa = \@a[0];
";

# Scalar value @a[0] better written as $a[0] at (eval 15) line 3.
ok $str =~ /\@a\[0\]/; 

logger ('debug')->appender (*STDERR);

debug "debug test"; # string # 28

ok $str =~ /\[$$\] \[main\(\d+\)\] \[debug\] debug test/m, $str;

print $str;

undef $err;
untie *STDERR;

ok $str; #, "warnings is turned on by Class::Easy; warning is: $err";

# ok ! $^W, "warnings is not turned on globally";

1;
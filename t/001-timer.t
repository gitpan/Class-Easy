#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw(no_plan);

use Data::Dumper;

use Class::Easy;

# without Class::Easy::DEBUG
my $t = timer ('sleep one second');

ok ! defined $t->[0];

ok 0 == $t->lap ('one more second');

ok 0 == $t->end;

ok 0 == $t->total;

# with Class::Easy::DEBUG
$Class::Easy::DEBUG = 1;

$t = timer ('sleep one second');

ok $t->[0] eq 'sleep one second';

sleep (1);

my $interval = $t->lap ('one more second');

ok $interval >= 1;

sleep (1);

$interval = $t->end;

ok $interval >= 1;

$interval = $t->total;

ok $interval >= 2;

1;
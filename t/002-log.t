#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw(no_plan);

use Data::Dumper;

use Class::Easy;
use Class::Easy::Log;

ok !$Class::Easy::LOG;

debug "test";

ok !$Class::Easy::LOG, 'we don\'t want anything before DEBUG';

$Class::Easy::DEBUG = 1;

debug "test";

ok $Class::Easy::LOG =~ /\[$$\] \[main[^\]]+\] \[DBG\] test/, $Class::Easy::LOG;

ok 1;

my $log = '';

$Class::Easy::LOGGER = sub {
	$log .= shift;
};

debug "test2";

ok $Class::Easy::LOG !~ /\[$$\] \[main[^\]]+\] \[DBG\] test2/;

ok $log =~ /\[$$\] \[main[^\]]+\] \[DBG\] test2/;

1;
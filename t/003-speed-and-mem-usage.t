#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw(no_plan);

use Data::Dumper;

use Class::Easy;

my $speed_test = My::SpeedTest->new;

my $t = timer;

my $failed = undef;

foreach my $id (0 .. 10000) {
	my $method = "id_$id";
	unless ($speed_test->$method eq $id) {
		warn "$id failed";
		$failed = $id;
		last;
	}
}

my $elapsed = $t->end;

warn "10000 accessors examined in $elapsed, engine " . $speed_test->engine . "\n";

ok ! defined $failed;

eval {
	require Moose;
};

if (! $@ and exists $INC{'Moose.pm'}) {

	$speed_test = My::SpeedTest2->new;
	
	$t = timer;
	
	$failed = undef;
	
	foreach my $id (0 .. 10000) {
		my $method = "id_$id";
		unless ($speed_test->$method eq $id) {
			warn "$id failed";
			$failed = $id;
			last;
		}
	}
	
	
	$elapsed = $t->end;
	
	warn "10000 accessors examined in $elapsed, engine " . $speed_test->engine . "\n";
	
	ok ! defined $failed;
	
}

eval {
	require Class::Data::Inheritable;
};

if (! $@ and exists $INC{'Class/Data/Inheritable.pm'}) {

	$speed_test = My::SpeedTest3->new;
	
	$t = timer;
	
	$failed = undef;
	
	foreach my $id (0 .. 10000) {
		my $method = "id_$id";
		unless ($speed_test->$method eq $id) {
			warn "$id failed";
			$failed = $id;
			last;
		}
	}
	
	$elapsed = $t->end;
	
	warn "10000 accessors examined in $elapsed, engine " . $speed_test->engine . "\n";
	
	ok ! defined $failed;
	
}

package My::SpeedTest;

use Class::Easy;

use Time::HiRes qw(gettimeofday tv_interval);

sub engine {
	return "Class::Easy";
}

BEGIN {
	
	my ($mem) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	my $t0 = [gettimeofday];

	foreach my $id (0 .. 10000) {
		has "id_$id", default => $id;
	}
	
	my $elapsed = tv_interval ( $t0);
	my ($mem2) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	
	warn "10000 accessors completed in $elapsed, engine " . __PACKAGE__->engine . ", memory consumed: "
		. ($mem2 - $mem)
		." KB\n";

};

sub new {
	my $class = shift;
	
	bless {}, $class;
}

1;

package My::SpeedTest2;

use strict;

use Time::HiRes qw(gettimeofday tv_interval);

sub engine {
	return "Moose";
}

BEGIN {
	
	eval {
		require Moose;
	};
	
	if (! $@ and exists $INC{'Moose.pm'}) {
	
	import Moose;
	
	my ($mem) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	my $t0 = [gettimeofday];

	#foreach my $id (0 .. 10000) {
	#	has ("id_$id", default => $id);
	#}
	
	my $elapsed = tv_interval ( $t0);
	my ($mem2) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	
	warn "10000 accessors completed in $elapsed, engine " . __PACKAGE__->engine . ", memory consumed: "
		. ($mem2 - $mem)
		." KB\n";
	
	}
};
 
1;

package My::SpeedTest3;

use strict;

use Time::HiRes qw(gettimeofday tv_interval);

sub engine {
	return "Class::Data::Inheritable";
}

BEGIN {
	
	eval {
		require Class::Data::Inheritable;
	};
	
	if (! $@ and exists $INC{'Class/Data/Inheritable.pm'}) {
	
	import Class::Data::Inheritable;
	use base qw(Class::Data::Inheritable);
	
	my ($mem) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	my $t0 = [gettimeofday];

	foreach my $id (0 .. 10000) {
		__PACKAGE__->mk_classdata ("id_$id" => $id);
	}
	
	my $elapsed = tv_interval ( $t0);
	my ($mem2) = `ps -p $$ -xwww -o rss | grep -v RSS` =~ /(\d+)/;
	
	warn "10000 accessors completed in $elapsed, engine " . __PACKAGE__->engine . ", memory consumed: "
		. ($mem2 - $mem)
		." KB\n";
	
	}
};

sub new {
	my $class = shift;
	
	bless {}, $class;
}


1;

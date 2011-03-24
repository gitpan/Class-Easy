package Class::Easy::Timer;
# $Id: Timer.pm,v 1.3 2009/07/20 18:00:10 apla Exp $

use strict;
use warnings;

use Time::HiRes qw(gettimeofday tv_interval);

require Class::Easy;
require Class::Easy::Log;

sub timer {
	Class::Easy::Timer->new (@_);
}

sub new {
	my $class = shift;
	
	my $logger = Class::Easy::Log::logger ('debug');
	
	if (ref $_[-1] eq 'Class::Easy::Log') {
		$logger = pop @_;
	}
	
	my $msg   = join (' ', @_) || '';
	
	return bless [], $class
		unless $logger->{tied};
	
	my $t = [gettimeofday];
	
	bless [$msg, $t, $t, undef, $logger], $class;
}

sub lap {
	my $self = shift;
	my $msg  = shift || '';
	
	return 0
		unless $self->[4]->{tied};
	
	my $interval = tv_interval ($self->[1]);
	
	my $caller1  = [caller (1)];
	my $caller0  = [caller];

	Class::Easy::Log::_wrapper (
		$self->[4]->{category}, $self->[4], $caller1, $caller0,
		"$self->[0]: " . $interval*1000 . 'ms'
	);
	
	$self->[0] = $msg;
	
	$self->[1] = [gettimeofday];
	
	return $interval;
	
}

sub end {
	my $self = shift;
	
	return 0
		unless $self->[4]->{tied};

	my $interval = tv_interval ($self->[1]);
	
	$self->[3] = $interval;
	
	my $caller1  = [caller (1)];
	my $caller0  = [caller];

	Class::Easy::Log::_wrapper (
		$self->[4]->{category}, $self->[4], $caller1, $caller0,
		"$self->[0]: " . $interval*1000 . 'ms'
	);
	
	return $interval;
}

sub total {
	my $self = shift;
	
	return 0
		unless $self->[4]->{tied};

	return $self->[3]
		unless $self->[2];
	
	my $interval = tv_interval ($self->[2], $self->[1]) + $self->[3];

	my $caller1  = [caller (1)];
	my $caller0  = [caller];

	Class::Easy::Log::_wrapper (
		$self->[4]->{category}, $self->[4], $caller1, $caller0,
		"total time: " . $interval*1000 . 'ms'
	);
	
	return $interval;
}


1;
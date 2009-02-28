package Class::Easy::Timer;
# $Id: Timer.pm,v 1.2 2009/01/22 07:03:55 apla Exp $

use strict;
use warnings;

use Time::HiRes qw(gettimeofday tv_interval);

require Class::Easy;
require Class::Easy::Log;

sub new {
	my $class = shift;
	my $msg   = shift || '';
	
	return bless [], $class
		unless $Class::Easy::DEBUG;
	
	my $t = [gettimeofday];
	
	bless [$msg, $t, $t], $class;
}

sub lap {
	my $self = shift;
	my $msg  = shift || '';
	
	return 0
		unless $Class::Easy::DEBUG;
	
	my $interval = tv_interval ($self->[1]);
	
	Class::Easy::Log::debug_depth ("$self->[0]: " . $interval*1000 . 'ms');
	
	$self->[0] = $msg;
	
	$self->[1] = [gettimeofday];
	
	return $interval;
	
}

sub end {
	my $self = shift;
	
	return 0
		unless $Class::Easy::DEBUG;

	my $interval = tv_interval ($self->[1]);
	
	$self->[3] = $interval;
	
	Class::Easy::Log::debug_depth ("$self->[0]: " . $interval*1000 . 'ms');
	
	return $interval;
}

sub total {
	my $self = shift;
	
	return 0
		unless $Class::Easy::DEBUG;

	return $self->[3]
		unless $self->[2];
	
	my $interval = tv_interval ($self->[2], $self->[1]) + $self->[3];
	
	Class::Easy::Log::debug_depth ("total time: " . $interval*1000 . 'ms');
	
	return $interval;
}


1;
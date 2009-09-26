package Class::Easy::Log;
# $Id: Log.pm,v 1.3 2009/07/20 18:00:10 apla Exp $

use strict;
use warnings;

require Class::Easy;

$Class::Easy::LOGGER = sub {
	$Class::Easy::LOG .= shift;
};

sub context {
	my $depth = shift || 1;

	# my ($package, $filename, $line, $subroutine, $hasargs, $wantarray,
	# $evaltext, $is_require, $hints, $bitmask)
	my $sub  = (caller ($depth+1))[3];
	my $line = (caller ($depth))[2];

	return $sub, $line;

}

sub debug_depth {
    return
        unless $Class::Easy::DEBUG;
    my $message   = join '', @_;
    
    my $depth = 1;
    
	my $sub  = (caller ($depth+1))[3] || 'main';
	my $line = (caller ($depth))[2];
    
    $message = "[$$] [$sub($line)] [DBG] $message\n";
    
    &$Class::Easy::LOGGER ($message);
    warn $message
    	if $Class::Easy::DEBUG eq 'immediately';
    
}

sub debug {
    return
        unless $Class::Easy::DEBUG;
    my $message   = join '', @_;
    
	my $sub  = (caller (1))[3] || 'main';
	my $line = (caller)[2];
    
    $message = "[$$] [$sub($line)] [DBG] $message\n";
    
    &$Class::Easy::LOGGER ($message);
    warn $message
    	if $Class::Easy::DEBUG eq 'immediately';
    
}

sub critical {
	my $message  = join '', @_ ;

	my $sub  = (caller (1))[3] || 'main';
	my $line = (caller)[2];

	&$Class::Easy::LOGGER ($message);
	die "[$$] [$sub($line)] [DIE] $message\n";
}


1;
package Class::Easy;
# $Id: Easy.pm,v 1.4 2009/07/20 18:00:12 apla Exp $

use vars qw($VERSION);
$VERSION = '0.04';

use strict;
use warnings;

no strict qw(refs);
no warnings qw(redefine);

require Class::Easy::Timer;

use File::Spec ();

our @EXPORT = qw(has try_to_use make_accessor set_field_values timer attach_paths);

our %EXPORT_FOREIGN = (
	'Class::Easy::Log' => [qw(debug critical debug_depth)],
	# 'Class::Easy::Timer' => [qw(timer)],
);

our $LOG = '';

sub timer {
	return Class::Easy::Timer->new (@_);
}

sub import {
	my $mypkg = shift;
	my $callpkg = caller;
	
	my %params = @_;
	
	warnings->import;
	strict->import;
	
	no strict 'refs';
	
	# export subs
	*{"$callpkg\::$_"} = \&{"$mypkg\::$_"} foreach @EXPORT;
	foreach my $p (keys %EXPORT_FOREIGN) {
		*{"$callpkg\::$_"} = \&{"$p\::$_"} foreach @{$EXPORT_FOREIGN{$p}};
	}
	
	use strict 'refs';
}

sub cleanup {
	$LOG = '';
}

sub has ($;%) {
	
	my ($caller) = caller;
	my $accessor = shift;
	
	return make_accessor ($caller, $accessor, @_);
}

sub make_accessor ($;$;$;%) {
	my $caller = shift;
	my $name   = shift;
	die caller if scalar @_ % 2;
	my %config = @_;
	
	my $isa     = $config{isa};
	my $is      = $config{is} || 'ro';
	my $default = $config{default};
	
	$config{global} = 1
		if defined $default and $is eq 'ro';
	
	my $mode;
	$mode = 1 if $is eq 'ro';
	$mode = 2 if $is eq 'rw';
	
	die "unknown accessor type: $is"
		unless $is =~ /^r[ow]$/;
	
	no strict 'refs';
	
	my $full_ref = "${caller}::$name";
	
	if (ref $default eq 'CODE') {
		
		*{$full_ref} = $default;
	
	} elsif ($config{global}) {
		
		*{$full_ref} = sub {
			
			my $c = @_;
			
			# return &$default if $c == 1 and ref $default eq 'CODE';
			return $default if $c == 1;
			_has_error ($caller, $name, $c - 1) if $c ^ $mode;
			
			make_accessor (ref $_[0] || $_[0], $name, %config, default => $_[1]);
		};
		
	} else {
		*{$full_ref} = sub {
			
			my $c = @_;
			
			#return &{$_[0]->{$name}} if $c == 1 and ref $_[0]->{$name} eq 'CODE';
			return $_[0]->{$name} if $c == 1;
			_has_error ($caller, $name, $c - 1) if $c ^ $mode;
			
			$_[0]->{$name} = $_[1];

		};
		
	}
}

sub set_field_values {
	my $self   = shift;
	my %params = @_;
	
	foreach my $k (keys %params) {
		$self->$k ($params{$k});
	}
}

sub _has_error {
	my $caller = shift;
	my $name   = shift;
	my $argc   = shift;
	
	my ($acc_caller, $line) = (caller(1))[0, 2];
	die "too many parameters ($argc) for accessor $caller\->$name at $acc_caller line $line.\n";
}

sub try_to_use {
	my @chunks = @_;
	
	my $package = join  '::', @chunks;
	@chunks     = split '::', $package;
	my $path    = join ('/', @chunks) . '.pm';
	
	no strict qw(refs);
	
	local $@;
	
	if (! exists $INC{$path} or ! eval ("scalar grep {!/\\w+\:\:/} keys \%$package\::;")) {
		eval "use $package";
	}
	
	use strict qw(refs);
	
	if ($@) {
		Class::Easy::Log::debug ("i can't load module ($path): $@");
		return;
	}
	
	return 1;
}

sub attach_paths {
	my $class = shift;
	
	my @pack_chunks = split(/\:\:/, $class);
	
	my $FS = 'File::Spec';
	
	my $pack_path = $FS->join (@pack_chunks) . '.pm';
	my $pack_inc_path = $INC{$pack_path};
	
	my $pack_abs_path = $FS->rel2abs ($pack_inc_path);
	
	make_accessor ($class, 'package_path', default => $pack_abs_path);
	
	make_accessor ($class, 'lib_path', default => $FS->canonpath (
		$pack_abs_path =~ /(.*)$pack_path$/
	));
}

sub list_subs {
	my $module = shift || (caller)[0];

	no strict 'refs';

	my %internal = (map {$_ => 1} qw(BEGIN UNITCHECK CHECK INIT END CLONE CLONE_SKIP));
	
	my @method_list = grep {
		! exists $internal{$_}
	} keys %{"${module}::"};

	
	
}

1;

=head1 NAME

Class::Easy - make class routine easy

=head1 ABSTRACT

This module is a functionality compilation of some good modules from CPAN.
Ideas are taken from Class::Data::Inheritable, Class::Accessor, Modern::Perl
and Moose at least.

At the beginning I planned to create lightweight and feature-less drop-in
alternative to Moose. Now package contains tree modules: class accessors,
easy logging and timer for easy development.

=head1 SYNOPSIS

SYNOPSIS

	use Class::Easy; # automatic loading of strict and warnings

	has "property"; # make object accessor
	has "global", global => 1; # make global accessor

	# make subroutine in package main
	make_accessor ('main', 'initialize', default => sub {
		$::initialized = 1;
		return "initialized!";
	});

	# string "[PID] [PACKAGE(STRING)] [DBG] something" logged
	# only if $Class::Easy::DEBUG = 'immediately';
	debug "something";

	# BEWARE! all timer operations are calculated only
	# when $Class::Easy::DEBUG has true value for
	# easy distinguishing between debug and production

	my $t = timer ('long operation');
	# … long operation

	my $time = $t->lap ('another long op');
	# …

	$time = $t->end;
	# $time contains time between last 'lap' or 'timer'
	# and 'end' call

	$time = $t->total;
	# now $time contains total time between timer init
	# and end call

=head1 FUNCTIONS

=head2 has

create accessor in current scope

=cut

=head2 make_accessors

create accessor in selected scope

=cut

=head1 AUTHOR

Ivan Baktsheev, C<< <apla at the-singlers.us> >>

=head1 BUGS

Please report any bugs or feature requests to my email address,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-Easy>. 
I will be notified, and then you'll automatically be notified
of progress on your bug as I make changes.

=head1 SUPPORT



=head1 ACKNOWLEDGEMENTS



=head1 COPYRIGHT & LICENSE

Copyright 2008-2009 Ivan Baktsheev

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

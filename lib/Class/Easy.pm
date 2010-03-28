package Class::Easy;

use vars qw($VERSION);
$VERSION = '0.11';

use strict;
use warnings;

no strict qw(refs);
no warnings qw(redefine once);

require Class::Easy::Timer;

use File::Spec ();

our @EXPORT = qw(has try_to_use try_to_use_quiet try_to_use_inc try_to_use_inc_quiet make_accessor set_field_values timer attach_paths);

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
	
	my $default;
	
	$default = shift
		if scalar @_ == 1;
	
	die caller if scalar @_ % 2;
	my %config = @_;
	
	my $isa     = $config{isa};
	my $is      = $config{is} || 'ro';
	$default    = $config{default}
		if exists $config{default};
	
	$config{global} = 1
		if defined $default and $is eq 'ro';
	
	my $mode;
	$mode = 1 if $is eq 'ro';
	$mode = 2 if $is eq 'rw';
	
	die "unknown accessor type: $is"
		unless $is =~ /^r[ow]$/;
	
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

sub _try_to_use {
	my $use_lib = shift;
	my $quiet   = shift;
	my @chunks  = @_;

	my $package = join  '::', @chunks;
	@chunks     = split '::', $package;
	my $path    = join ('/', @chunks) . '.pm';
	
	$@ = '';
	
	if ($use_lib) {
		return 1
			if exists $INC{$path};
	} else {
		# OLD: we removed "or ! exists $INC{$path}" statement because
		# "used" package always available via symbol table
		if (eval ("scalar grep {!/\\w+\:\:/} keys \%$package\::;") > 0) {
			return 1;
		}
	}
	
	eval "use $package";
	
	use strict qw(refs);
	
	if ($@) {
		Class::Easy::Log::debug ("i can't load module ($path): $@")
			unless $quiet;
		return;
	}
	
	return 1;
}

sub try_to_use {
	return _try_to_use (0, 0, @_);
}

sub try_to_use_quiet {
	return _try_to_use (0, 1, @_);
}

sub try_to_use_inc {
	return _try_to_use (1, 0, @_);
}

sub try_to_use_inc_quiet {
	return _try_to_use (1, 1, @_);
}

sub cannot_locate {
	my $error = shift;
	return 1 if $error =~ /Can't locate [^\.]+\.pm in \@INC/ms;
	return 0;
}

sub attach_paths {
	my $class = shift;
	
	my @pack_chunks = split(/\:\:/, $class);
	
	my $FS = 'File::Spec';
	
	my $pack_path = join ('/', @pack_chunks) . '.pm';
	my $pack_inc_path = $INC{$pack_path};

	$pack_path = $FS->canonpath ($pack_path);
	
	my $pack_abs_path = $FS->rel2abs ($FS->canonpath ($pack_inc_path));
	make_accessor ($class, 'package_path', default => $pack_abs_path);
	
	my $lib_path = substr ($pack_abs_path, 0, rindex ($pack_abs_path, $pack_path));
	make_accessor ($class, 'lib_path', default => $FS->canonpath ($lib_path));
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
	
	# try to load package IO::Easy, return 1 when success
	try_to_use ('IO::Easy');
	
	# try to load package IO::Easy, but search for package existence
	# within %INC instead of symbolic table
	try_to_use_inc ('IO::Easy');
	
	# for current package
	has "property_ro"; # make readonly object accessor
	has "property_rw", is => 'rw'; # make readwrite object accessor
	
	has "global25", default => 25; # make readonly static accessor with value 25
	has "global", global => 1, is => 'rw'; # make readwrite static accessor

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

=head2 has ($name [, is => 'ro' | 'rw'] [, default => $default], [, global => 1])

create accessor named $name in current scope

=cut

=head2 make_accessor ($scope, $name)

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

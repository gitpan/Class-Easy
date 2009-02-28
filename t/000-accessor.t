#!/usr/bin/perl

use warnings;
use strict;

use Test::More qw(no_plan);

use Data::Dumper;

use_ok ('Class::Easy');

my $circle = My::Circle->new;

$circle->dim_x (2);
$circle->dim_y (3);

warn Dumper $circle;

ok $circle->dim_x == 2;
ok $circle->dim_y == 3;

ok $circle->id == 2345;

$circle->global_hash->{1} = 1;
ok $circle->global_hash->{1} == 1;

ok ! defined $circle->global_hash_rw;

$circle->global_hash_rw ({'aaa' => 'aaa'});
ok $circle->global_hash_rw->{'aaa'} eq 'aaa';

eval {$circle->id (1);};
ok $@ =~ /^too many parameters/, "ERROR: $@";

# warn Dumper \%My::Circle::__accessors;

my $ellipse = My::Ellipse->new;

#warn Dumper $ellipse->global_hash_rw;
#die 'jopa' if ref $ellipse->global_hash_rw eq 'HASH';

#ok ! defined $ellipse->global_hash_rw;

$ellipse->global_hash_rw ({});

ok ! scalar keys %{$ellipse->global_hash_rw};

ok scalar keys %{$circle->global_hash_rw};

# die;

warn Dumper $circle->global_hash_rw;

my $sphere = My::Sphere->new;
$sphere->dim_x (2);
$sphere->dim_y (3);

ok $sphere->dim_x == 2;
ok $sphere->dim_y == 3;

$sphere->dim_z (4);
ok $sphere->dim_z == 4;

$sphere->global_one ('test');

$sphere->global_one_defined ('la-la-la');

eval {$sphere->global_ro (1);};
ok $@ =~ /^too many parameters/, "ERROR: $@";

ok $sphere->sub_z eq $sphere->dim_z;

make_accessor ('My::Sphere', 'accessor', default => sub {
	my $self = shift;
	
	return $self->global_one;
});

ok $sphere->accessor eq $sphere->global_one;

1;

package My::Circle;

use strict;

use Class::Easy;

BEGIN {
	has 'id';
	has 'dim_x', is => 'rw';
	has 'dim_y', is => 'rw';
	has 'global_hash', default => {};
	has 'global_hash_rw', is => 'rw', global => 1;
};

sub new {
	my $class = shift;
	my $self  = {id => 2345};
	
	bless $self, $class;
}

1;

package My::Sphere;

use strict;

use Class::Easy;

BEGIN {
	use base 'My::Circle';
	has 'dim_z', is => 'rw';
	has 'global_one', is => 'rw', global => 1;
	has 'global_one_defined', is => 'rw', global => 1, default => 'defined';
	has 'global_ro', default => 'ro';
	has 'sub_z', default => sub {
		my $self = shift;
		
		return $self->dim_z;
	}
};

package My::Ellipse;

use strict;

use Class::Easy;

BEGIN {
	use base 'My::Circle';
};


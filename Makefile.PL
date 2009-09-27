use 5.008006;
use ExtUtils::MakeMaker 6.48;

WriteMakefile(
	NAME => "Class::Easy",
	VERSION_FROM => "lib/Class/Easy.pm",
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	AUTHOR => 'Ivan Baktsheev <dot.and.thing@gmail.com>',
	MIN_PERL_VERSION => '5.8.6', # mac os x 10.4.11 at least, i don't want any older shit
	PREREQ_PM => {
		'IO::Scalar'    => 0,
		'File::Spec'    => 0,
		'Time::HiRes'   => 0,
		'ExtUtils::MakeMaker' => '6.48',
	}
);

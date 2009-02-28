use ExtUtils::MakeMaker;

WriteMakefile(
	NAME => "Class::Easy",
	VERSION_FROM => "lib/Class/Easy.pm",
	'dist' => { COMPRESS=>"gzip", SUFFIX=>"gz" },
	AUTHOR => 'Ivan Baktsheev <dot.and.thing@gmail.com>',
	PREREQ_PM => {
		'IO::Scalar'    => 0,
		'File::Spec'    => 0,
		'Time::HiRes'   => 0,
	}
);

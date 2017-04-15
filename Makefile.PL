use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

( my $mmv = ExtUtils::MakeMaker->VERSION ) =~ s/ _ //smxg;

my %arg = (
    'AUTHOR'		=> 'Simon Drabble (sdrabble@cpan.org)',
    'ABSTRACT'		=> 'Extract tables from HTML',
    'NAME'		=> 'HTML::TableContentParser',
    'VERSION_FROM'	=> 'TableContentParser.pm', # finds $VERSION
    'PREREQ_PM'		=> {
	'HTML::Parser'	=> 0,
	'strict'	=> 0,
    }, # e.g., Module::Name => 1.1
);

$mmv >= 6.31
    and $arg{LICENSE} = 'perl_5';

$arg{ $mmv >= 6.52 ? 'CONFIGURE_REQUIRES' : 'PREREQ_PM' }
    { 'ExtUtils::MakeMaker' } = 0;

$arg{ $mmv >= 6.64 ? 'TEST_REQUIRES' :
    $mmv >= 6.5503 ? 'BUILD_REQUIRES' : 'PREREQ_PM' }
    { 'Test' } = 0;

WriteMakefile( %arg );

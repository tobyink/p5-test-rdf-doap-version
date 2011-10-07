package Test::RDF::DOAP::Version;

use 5.008;
use common::sense;
use constant { FALSE => 0, TRUE => 1 };
use utf8;

use RDF::Trine qw[iri variable literal blank statement];
use Test::More;
use URI::Escape qw[uri_escape];

our $VERSION = '0.002';
our @EXPORT  = qw(doap_version_ok);
our $DOAP    = RDF::Trine::Namespace->new('http://usefulinc.com/ns/doap#');

use base qw[Exporter];

sub doap_version_ok
{
	my ($dist, $module) = @_;

	eval "use $module;";
	my $version  = $module->VERSION;	
	my $dist_uri = iri(sprintf('http://purl.org/NET/cpan-uri/dist/%s/project', uri_escape($dist)));
	
	my $model = RDF::Trine::Model->temporary_model;

	my $turtle = RDF::Trine::Parser->new('Turtle');
	while (<meta/*.{ttl,turtle,nt}>)
	{
		my $iri = URI::file->new_abs($_);
		$turtle->parse_file_into_model("$iri", $_, $model);
	}

	my $rdfxml = RDF::Trine::Parser->new('RDFXML');
	while (<meta/*.{rdf,rdfxml,rdfx}>)
	{
		my $iri = URI::file->new_abs($_);
		$rdfxml->parse_file_into_model("$iri", $_, $model);
	}
	
	my $pattern = RDF::Trine::Pattern->new(
		statement($dist_uri, $DOAP->release, variable('v')),
		statement(variable('v'), $DOAP->revision, literal($version, undef, 'http://www.w3.org/2001/XMLSchema#string')),
		);
	my $iter = $model->get_pattern($pattern);
	while (my $result = $iter->next)
	{
		pass('doap_version_ok');
		return 1;
	}

	$pattern = RDF::Trine::Pattern->new(
		statement($dist_uri, $DOAP->release, variable('v')),
		statement(variable('v'), $DOAP->revision, literal($version)),
		);
	$iter = $model->get_pattern($pattern);
	while (my $result = $iter->next)
	{
		pass('doap_version_ok');
		return 1;
	}

	fail('doap_version_ok');
	return 0;
}

# Your code goes here

TRUE;

=head1 NAME

Test::RDF::DOAP::Version - tests 'meta/changes.ttl' is up to date

=head1 DESCRIPTION

=over

=item C<< doap_version_ok($dist, $module) >>

Checks the distribution metadata matches the pattern:

	?dist doap:release ?rel .
	?rel doap:revision ?ver .

Where ?dist is the URI C<< http://purl.org/NET/cpan-uri/dist/%s/project >>
(C<< %s >> having been substituted for $dist) and ?ver is the $VERSION from
$module, as an xsd:string or plain literal.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Test-RDF-DOAP-Version>.

=head1 SEE ALSO

L<Module::Install::DOAPChangeSets>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.



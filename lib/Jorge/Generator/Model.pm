package Jorge::Generator::Model;

use warnings;
use strict;

=head1 NAME

Jorge::Generator::Model - Jorge based Models generator. Runs with jorge-generate

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

use Data::Dumper;
use Getopt::Long;
use Pod::Usage;
use Carp qw( croak );

=head1 FUNCTIONS

=head2 run

=cut

my @types = qw(
    bit
    char
    enum
    int
    text
    timestamp
    varchar
);


sub run {

    pod2usage() unless @ARGV;

    my %config;

    GetOptions(
        'model=s'    => \$config{model},
        'plural=s'   => \$config{plural},
        'fields=s'   => \$config{fields},
        help         => sub { pod2usage(); },
    ) or pod2usage();
    pod2usage() unless ($config{model} && $config{fields});
    
    my %fields = parse_fields($config{fields});
    print Dumper(%fields);
}

=doc
my %struct;
my @types = qw(
    bit
    char
    enum
    int
    text
    timestamp
    varchar
    );

foreach my $p (@params){
    my ($field, $value) = split(':', $p);
        die "missing param or value" unless $field && $value;
        die "invalid data type $value on $field" unless grep {$_ eq $value} @types;
    push(@{$struct{$value}}, $field);
}

print Dumper(%struct);
=cut

sub parse_fields{
    my $s = shift;
    my @fields = split(/,/,$s);
    my %return;
    
    foreach my $l (@fields){
        my ($field, $value) = split(':', $l);
        die "missing param or value" unless $field && $value;
        die "invalid data type \'$value\' on $field" unless grep {$_ eq $value} @types;
        $return{$field} = $value;
    }
    return %return;
}

#my ($action, $name) = split(':', shift @params);
#    die "missing param or value" unless $action && $name;

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Julián Porta, C<< <julian.porta at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jorge-generator at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Jorge-Generator>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Jorge::Generator::Model


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Jorge-Generator>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Jorge-Generator>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Jorge-Generator>

=item * Search CPAN

L<http://search.cpan.org/dist/Jorge-Generator/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Julián Porta, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Jorge::Generator::Model

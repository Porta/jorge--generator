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
use Carp qw( croak cluck);

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
    Class
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
    #$config{parsed_fields} = %fields;
    #print singular(%config);
    #print Dumper(%config);
    
}

sub parse_fields{
    my $s = shift;
    my @fields = split(/,/,$s);
    my %return;
    
    foreach my $l (@fields){
        my ($field, $value) = split(':', $l);
        croak "missing param or value" unless $field && $value;
        croak "invalid data type \'$value\' on $field" unless grep {$_ eq $value} @types;
        $return{$field} = $value;
    }
    return %return;
}


sub singular{

my %config = @_;



my $tmpl = <<END;
package $config{model};
use base 'Jorge::DBEntity';
use Jorge::Plugin::Md5;

#Insert any dependencies here.
#Example:
<tmpl_loop name="classes">
use <tmpl_var name="base_class">::<tmpl_var name="field">;</tmpl_loop>

use strict;

sub _fields {
    
    my \$table_name = '$config{model}';
    
    my \@fields = qw(
        $config{parsed_fields}
    );

    my \%fields = (
        Id => { pk => 1, read_only => 1 },<tmpl_loop name="classes">
        <tmpl_var name="field"> => { class => new <tmpl_var name="base_class">::<tmpl_var name="field">},</tmpl_loop><tmpl_loop name="enum">
#         <tmpl_var name="field"> => { values => qw(<tmpl_var name="values">)},</tmpl_loop><tmpl_loop name="timestamp">
        <tmpl_var name="field"> => { datetime => 1},</tmpl_loop>
    );

    return [ \\\@fields, \\\%fields, \$table_name ];
}

1;
END
print $tmpl;
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

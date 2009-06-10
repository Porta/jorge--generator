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
  datetime
  varchar
  pk
);

sub run {
    pod2usage() unless @ARGV;

    my %config;
    GetOptions(
        'model=s'  => \$config{_model},
        'plural=s' => \$config{_plural},
        'fields=s' => \$config{_fields},
        help       => sub { pod2usage(); },
    ) or pod2usage();

    pod2usage() unless ( $config{_model} && $config{_fields} );

    $config{_model}  = ucfirst( $config{_model} );
    $config{_plural} = ucfirst( $config{_plural} );

    #now, parse the fields we received.
    my @fields = split( /,/, $config{_fields} );
    foreach my $f (@fields) {
        my ( $field, $value ) = split( ':', $f );
        croak "missing param or value" unless $field && $value;
        
        my $its_a_class = $value =~ m/[A-Z](.*)/;
        croak "invalid data type \'$value\' on $field"
          if !( grep { $_ eq $value } @types or $its_a_class );

        $value = ucfirst $value;
        $field = ucfirst $field;

        if ($its_a_class){
            push( @{ $config{_classes} }, $value );
        }
        
        $config{$field} = $value;
        push( @{ $config{_order} }, $field );
    }    
    singular(%config);

}


sub singular {
    my %config = @_;
    my @use = @{$config{_classes}};
    my @fields_raw = @{$config{_order}};
    my $use_line = join( "", map { "use $_;\n" } @use );
    my @fields = grep { $config{$_} =~ m/[a-z]+/ } @fields_raw;
    
    my $fields_list = join( ",\n        ", map { $_ } @fields );
    #note the spacing. must match the number of spaces in the $tmpl var in
    # order to properly allign the fields
    my @pks = grep { $config{$_} eq 'Pk' } @fields;
    my @datetimes = grep { $config{$_} eq 'Timestamp' ||  $config{$_} eq 'Datetime' } @fields;
    my $pks_line = join("", map { "$_ => { pk => 1, read_only => 1 },\n" } @pks);
    my $datetime_line = join("", map { "$_ => { datetime => 1 },\n" } @datetimes);
    
    print Dumper($pks_line);
    
    my $tmpl = <<END;
package $config{_model};
use base 'Jorge::DBEntity';
use Jorge::Plugin::Md5;

#Insert any dependencies here.
#Example:
$use_line

use strict;

sub _fields {
    
    my \$table_name = '$config{_model}';
    
    my \@fields = qw(
        $fields_list
    );

    my \%fields = (
        $pks_line
        $datetime_line
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

1;    # End of Jorge::Generator::Model


package IncomeTax::IND;

use strict; use warnings;

use overload q("") => \&as_string, fallback => 1;

use Carp;
use Readonly;
use Data::Dumper;

=head1 NAME

IncomeTax::IND - Interface to Income Tax of India.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $DEBUG   = 1;

Readonly my $TAX_SLAB =>
{
    'm' => [ { min => 0,        max  => 1_60_000, rate => 0.00 },
             { min => 1_60_000, max  => 5_00_000, rate => 0.10 },
             { min => 5_00_000, max  => 8_00_000, rate => 0.20 },
             { min => 8_00_000, rate => 0.30 } ],
    'f' => [ { min => 0,        max  => 1_90_000, rate => 0.00 },
             { min => 1_90_000, max  => 5_00_000, rate => 0.10 },
             { min => 5_00_000, max  => 8_00_000, rate => 0.20 },
             { min => 8_00_000, rate => 0.30 } ],
    's' => [ { min => 0,        max  => 2_40_000, rate => 0.00 },
             { min => 2_40_000, max  => 5_00_000, rate => 0.10 },
             { min => 5_00_000, max  => 8_00_000, rate => 0.20 },
             { min => 8_00_000, rate => 0.30 } ],
};

Readonly my $EDUCATION_CESS     => 0.03;
Readonly my $SENIOR_CITIZEN_AGE => 60;

=head1 DESCRIPTION

The government of India imposes income tax  on  taxable income of individuals, Hindu Undivided
Families (HUFs),  companies,  firms,  co-operative societies and trusts (identified as body of 
individuals & association of persons) and any other artificial person. Levy of tax is separate
on  each  of  the persons. The levy is governed by the Indian Income Tax Act, 1961. The Indian
Income  Tax Department is governed by the Central Board for Direct Taxes (CBDT) and is part of
the Department of Revenue under the Ministry of Finance, Govt. of India.

Every  Person  whose  total  income  exceeds the maximum amount which is not chargeable to the
income  tax  is  an  assesse,  and  shall be chargeable to the income tax at the rate or rates
prescribed under the finance act for the relevant assessment year shall be determined on basis
of his residential status.

Income tax  is  a tax payable, at the rate enacted by the Union Budget (Finance Act) for every
Assessment Year, on the Total Income earned in the Previous Year by every Person.

=head1 CONSTRUCTOR

The constructor expects a reference to an anonymous hash as input parameter. Table below shows
the possible value of various key and value pairs.

    +--------------+------------------------------------+
    | Key          | Value                              |
    +--------------+------------------------------------+
    | sex          | m | f                              |
    | age          | Age of the person.                 |
    | gross_income | Gross income for the year 2010-11. |
    +--------------+------------------------------------+

    use stric; use warnings;
    use IncomeTax::IND;
    
    my $ind = IncomeTax::IND->new({ sex => 'm', age => 35, gross_income => 8_00_000});

=cut

sub new
{
    my $class = shift;
    my $param = shift;
    
    _validate_param($param);
    bless $param, $class;
    return $param;
}

=head1 METHODS

=head2 get_income_tax()

Returns Income Tax based on tax year 2010-11 according to Indian Goverment Constitution.

    use stric; use warnings;
    use IncomeTax::IND;
    
    my $ind = IncomeTax::IND->new({ sex => 'm', age => 35, gross_income => 8_00_000});
    my $income_tax = $ind->get_income_tax();

=cut

sub get_income_tax
{
    my $self = shift;
    
    my ($type, $total_tax, $breakdown);
    $type = $self->{sex};
    $type = 's' if $self->{age} >= $SENIOR_CITIZEN_AGE;
    foreach (@{$TAX_SLAB->{lc($type)}})
    {
        if ((exists($_->{max}) && ($_->{max} <= $self->{gross_income})) 
            || 
            ($_->{min} <= $self->{gross_income}))
        {
            $_->{max} = $self->{gross_income} unless exists($_->{max});
            $total_tax += ($_->{max} - $_->{min}) * $_->{rate};
            push @{$breakdown}, 
                { min => $_->{min}, max => $_->{max}, rate => $_->{rate},
                  tax => (($_->{max} - $_->{min}) * $_->{rate}) };
        }
    }
    
    $self->{breakdown} = $breakdown;
    $self->{total_tax} = $total_tax;
    $self->{education_cess} = $total_tax * $EDUCATION_CESS;
    $self->{income_tax}     = sprintf("%.02f", ($self->{total_tax} + $self->{education_cess}));
    return $self->{income_tax};
}

=head2 show_breakdown()

Print the tax calculation breakdown. You should ONLY be calling after method get_income_tax().
Otherwise if it would simply return nothing.

    use stric; use warnings;
    use IncomeTax::IND;
    
    my $ind = IncomeTax::IND->new({ sex => 'm', age => 35, gross_income => 8_00_000});
    my $income_tax = $ind->get_income_tax();
    $ind->show_breakdown();

=cut

sub show_breakdown
{
    my $self = shift;
    print $self->as_string();
}

=head2 as_string()

Same as show_breakdown() except that it gets called when printing object in scalar context.

    use stric; use warnings;
    use IncomeTax::IND;
    
    my $ind = IncomeTax::IND->new({ sex => 'm', age => 35, gross_income => 8_00_000});
    my $income_tax = $ind->get_income_tax();
    print $ind->as_string();
    
    # or simply
    
    print $ind;

=cut

sub as_string
{
    my $self   = shift;
    my $string = '';
    foreach (@{$self->{breakdown}})
    {
        next if (($_->{min} !=0) && ($_->{tax} == 0));
        $string .= sprintf("Tax on Income between %d - %d @ %.02f%s : %.02f\n", 
            $_->{min}, $_->{max}, ($_->{rate}*100), '%', $_->{tax});
    }
    $string .= sprintf("Total Tax: %.02f\n", $self->{total_tax});
    $string .= sprintf("Education Cess @ %.02f%s of Total Tax: %.02f\n", ($EDUCATION_CESS*100), '%', $self->{education_cess});
    $string .= sprintf("Net Tax Payable: %.02f\n", $self->{income_tax});
    return $string;
}

sub _validate_param
{
    my $param = shift;
    croak("ERROR: Missing input parameters.\n") 
        unless defined $param;
    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($param) ne 'HASH');
    croak("ERROR: Missing key sex.\n")
        unless exists($param->{sex});
    croak("ERROR: Missing key gross_income.\n")
        unless exists($param->{gross_income});
    croak("ERROR: Missing key age.\n")
        unless exists($param->{age});
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        unless (scalar(keys %{$param}) == 3);
    croak("ERROR: Invalid value for key sex.\n")
        unless ($param->{sex} =~ /^[m|f]$/i);
    croak("ERROR: Invalid value for key age.\n")
        unless ($param->{age} =~ /^\d+$/);
    croak("ERROR: Invalid value for key gross_income.\n")
        unless ($param->{gross_income} =~ /^\d+\.?\d+?$/);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-incometax-ind at rt.cpan.org>,  or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IncomeTax-IND>.I will be 
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IncomeTax::IND

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IncomeTax-IND>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IncomeTax-IND>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IncomeTax-IND>

=item * Search CPAN

L<http://search.cpan.org/dist/IncomeTax-IND/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed  in  the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of IncomeTax::IND
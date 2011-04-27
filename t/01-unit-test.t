#!perl

use strict; use warnings;
use IncomeTax::IND;
use Test::More tests => 12;

my ($ind);

$ind = IncomeTax::IND->new({sex => 'm', age => 35, gross_income => 8_00_000});
is($ind->get_income_tax(), "96820.00");

$ind = IncomeTax::IND->new({ sex => 'f', age => 35, gross_income => 12_00_000});
is($ind->get_income_tax(), "217330.00");

$ind = IncomeTax::IND->new({ sex => 'f', age => 67, gross_income => 8_00_000});
is($ind->get_income_tax(), "88580.00");

eval { $ind = IncomeTax::IND->new(); };
like($@, qr/ERROR: Missing input parameters./);

eval { $ind = IncomeTax::IND->new(sex => 'm'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $ind = IncomeTax::IND->new({sxe => 'm'}); };
like($@, qr/ERROR: Missing key sex./);

eval { $ind = IncomeTax::IND->new({sex => 'm', grossincome => 8_00_0000}); };
like($@, qr/ERROR: Missing key gross_income./);

eval { $ind = IncomeTax::IND->new({sex => 'm', gross_income => 8_00_0000, aeg => 35}); };
like($@, qr/ERROR: Missing key age./);

eval { $ind = IncomeTax::IND->new({sex => 'm', gross_income => 8_00_0000, age => 35, xyz => 1}); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $ind = IncomeTax::IND->new({sex => 's', gross_income => 8_00_0000, age => 35}); };
like($@, qr/ERROR: Invalid value for key sex./);

eval { $ind = IncomeTax::IND->new({sex => 'm', gross_income => 'abc', age => 35}); };
like($@, qr/ERROR: Invalid value for key gross_income./);

eval { $ind = IncomeTax::IND->new({sex => 'm', gross_income => 8_00_0000, age => 'abc'}); };
like($@, qr/ERROR: Invalid value for key age./);
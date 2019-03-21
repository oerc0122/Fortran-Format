#!/usr/bin/env perl
# Real_check is a tool to check whether floats are followed by a kind specifier in Fortran
# Written by J. Wilkins 2017

$float=qr/((?>\d+\.(?>\d+)?(?>[eE][+ -]?\d+)?))/;
$lop  =qr/(?:eq|ge|gt|le|lt|and|or|xor|neqv|eqv|not|neq)/;
$i=0;
while (<>) {
    $i++;
    if (/[^vViIbBoOzZfFeEnNsSgGdD0-9]$float(?!(?:$lop|_))/ && !/^\s*!/) {print $i,$_;}
}

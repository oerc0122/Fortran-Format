#!/usr/bin/env perl
# Texttofmt is a tool to convert ASCII tables into Fortran format statements or write statements.
# Written by J. Wilkins 2015

use Getopt::Long;

GetOptions (
    "format" => \$format,
    "write"  => \$write,
    "help"   => \$help
);

if ($help) {
    print "Texttofmt is a tool to convert ASCII tables into Fortran format statements or write statements.
Reads table from stdin and creates associated format or write statements.
-h displays this help
Available flags are -f or -w to specify whether to output format statements or write statements. Default is to write.
";
    exit 1
}

$style = "write";
$style = "fmt" if $format;
die "Both formats specified" if $format && $write;

$character=qr/\b(a{2,})\b/;
$integer=  qr/\b(i+)\b/;
$real=     qr/\b(f+)\.?(f+)?\b/;
$space=    qr/(\s+)/;
$repeat=qr/(.)\1{4,}/;
$CHARACTER = qr/[0-9]*A[0-9]+/;
$INTEGER   = qr/[0-9]*I[0-9]+/;
$REAL	   = qr/[0-9]*F[0-9]+(\.[0-9]+)?/;
$SPACE	   = qr/[0-9]+X/;
$MISC      = qr/\".*\"/;
$segment=qr/($CHARACTER|$INTEGER|$REAL|$SPACE|$MISC)/;
$repeat_segment=qr/(($segment,\s*($segment,)?)\2+)/;

$fmtcount = 100;

foreach $line (<>) {

    chomp $line;
    $vars = "";
    $varcount = 0;

    while ($line =~ $character){
	$num = length $1;
	$char = "A";
	$line =~ s/a+/$char$num,/;
	$varcount++;
	$vars .= " character".$varcount.",";
    }

    $varcount = 0;

    while($line =~ $integer){
	$num = length $1;
	$char = "I";
	$line =~ s/i+/$char$num,/;
	$varcount++;
	$vars .= " integer".$varcount.",";
    }

    $varcount = 0;

    while($line =~ $real){
	$num = (length $1);
	$char = "F";
	$num2 = length $2;
	$prenum=$num + $num2 + 1;
	if ($num2 == 0){
	    $line =~ s/f+/$char$num,/;
	} else {
	    $line =~ s/f+(\.f+)?/$char$prenum.$num2,/;
	}
	$varcount++;
	$vars .= " float".$varcount.",";
    }

    while($line =~ $space){
	$num = length $1;
	$char = "X";
	$line =~ s/$space/$num$char,/;
    }

    while($line =~ $repeat){
	$char = $1;
	$tmpchar = $char;
	$tmpchar =~ s/([?+*:|{}()^$\\[\]])/\\$1/g;
	$line =~ /($tmpchar{5,})/;
	$num = length $1;
	$line =~ s/$tmpchar{5,}/$num($char),/;
    }

    while($line =~ $repeat_segment){
	$num = length ($1)/length ($2);
	$char = $2;
	chop $char;
	$char = "(".$char."),";
	$line =~ s/$repeat_segment/$num$char/;
    }


    $line =~ s/([^FXIA0-9,.()]+)/\"$1\",/g;
    $line =~ s/,\)/)/g;
    $line =~ s/",1X,"/ /g;
    chop $line;
    chop $vars;
    if (length $line == 0) {
	if ($style eq "write") {
	    print "write(*,*)\n";
	}
    } else {
	if ($style eq "write") {
	    print "write(*,'(".$line.")')".$vars." \n";
	} else {
	    print $fmtcount." format(".$line.")\n";
	    $fmtcount++;
	}
    }


}

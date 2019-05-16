#! /usr/bin/perl --

#Copyright (c) 2009-2019, Jean-Francois Flot <http://dx.doi.org/10.1111/j.1755-0998.2009.02732.x>
#
#Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is
#hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
#
#THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
#INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
#ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
#USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
#OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

warnings;
use strict;
use Getopt::Std;
print "\n";

print "SeqPHASE command-line version, Step 1: generating PHASE input files from FASTA alignments\n\n";

print "Reference:\nFlot, J.-F. (2010) SeqPHASE: a web tool for interconverting PHASE input/output files and FASTA sequence alignments\nMolecular Ecology Ressources 10 (1): 162-166\n\n";

print "Usage: perl seqphase1.pl -1 <first type of input file> -2 <second type of input file> -3 <third type of input file> -p <prefix>\nFirst type of input file = FASTA alignment of sequences from homozygous individuals and from heterozygotes to be phased (1 sequence per individual).\nSecond type of input file = FASTA alignment of alignment of fake haplotypes from heterozygotes to be phased (2 sequences per individual).\nThird type of input file (optional)= FASTA alignment of known haplotypes of previously phased heterozygotes (2 sequences per individual).\nPrefix for output files is optional, default prefix is 'phase'.\n\n";

our ( $opt_1, $opt_2, $opt_3, $opt_p );

getopts('1:2:3:p:');

unless ( defined($opt_1) or ( defined($opt_2) ) ) {
    print "There is no input file to be phased!\n";
    exit;
}
$opt_p = 'phase' unless defined($opt_p);

my $error_count  = 0;
my $error_count2 = 0;
my $error_count3 = 0;
my $maxseqlength = 0;

my @authorized = (
    'a', 't', 'g', 'c', 'r', 'y', 'm', 'k', 'w', 's', 'n', 'A',
    'T', 'G', 'C', 'R', 'Y', 'M', 'K', 'W', 'S', 'N', '-', '?'
);
my @authorized_restricted =
  ( 'a', 't', 'g', 'c', 'n', 'A', 'T', 'G', 'C', 'N', '-', '?' );

#processing alignment 1
if ( defined($opt_1) ) {
    open( AL1, $opt_1 ) || die "Error: Cannot open input file $opt_1\n";
}
my @align1 = <AL1>;

#remove all comments and endline characters
chomp(@align1);
$/ = "\r";
chomp(@align1);
$/ = "\n";
if ( $#align1 == 0 ) {
    print
"Only 1 line detected in 1seq.fas!\nPlease check data format (opening the alignment in
MEGA (http://www.megasoftware.net/) and exporting it as FASTA again may solve the problem;
alternatively, there may be a problem with end-of-line characters, for instance if your file
was manually transferred between computers using different operating systems (Linux, Macintosh or Windows;
see http://en.wikipedia.org/wiki/Newline for details): please make sure that the end-of-line characters in
your FASTA file match the operating system of the computer on which you are running SeqPHASE).\n";
    exit;
}
for ( my $i = 0 ; $i <= $#align1 ; $i++ ) {
    if ( substr( $align1[$i], 0, 1 ) eq ';' ) {
        splice( @align1, $i, 1 );
        $i = $i - 1;
    }
}

#makes a two-column table
my @table1;
my $j = -1;
for ( my $i = 0 ; $i <= $#align1 ; $i++ ) {
    if ( substr( $align1[$i], 0, 1 ) eq '>' ) {
        $j++;
        $table1[$j][0] = substr( $align1[$i], 1 );
        $table1[$j][1] = '';
    }
    else { $table1[$j][1] = $table1[$j][1] . $align1[$i] }
}

#removes spaces in the sequence column
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    $table1[$i][1] = join( '', ( split( ' ', $table1[$i][1] ) ) );
}

#sort sequences by alphabetical order
@table1 = sort { $a->[0] cmp $b->[0] } @table1;

#test for duplicate sequence names
for ( my $i = 0 ; $i < $#table1 ; $i++ ) {
    if ( $table1[$i][0] eq $table1[ $i + 1 ][0] ) {
        print "Repeat of name $table1[$i][0] encountered in alignment of sequences from homozygous individuals and from heterozygotes to be phased.\n";
        $error_count++;
    }
}

#test for unauthorized characters in sequences
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    my $control = $table1[$i][1];
    chomp($control);
    my @cont = split( '', $control );
    foreach my $r (@cont) {
        if ( $r ne '?' ) {
            if ( !grep( /$r/, @authorized ) ) {
                print "Unknown character state ($r) in $table1[$i][0] (in the alignment of sequences from homozygous individuals and from heterozygotes to be phased).\n";
                $error_count++;
            }
        }
    }
}

#find longest sequence
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    my $l = length( $table1[$i][1] );
    if ( $l > $maxseqlength ) { $maxseqlength = $l; $error_count2++ }
}

#processing alignment 3
if ( defined($opt_2) ) {
    open( AL3, $opt_2 ) || die "Error: Cannot open input file $opt_2\n";
}
my @align3 = <AL3>;
if ( substr( $align3[0], 0, 1 ) ne '' ) {
    if ( substr( $align3[0], 0, 1 ) ne '>' ) {
        print "The alignment of fake haplotypes from heterozygotes to be phased is not properly formatted, please input a FASTA file.";
        exit;
    }
}

#remove all comments and endline characters
if ( $#align3 == 0 ) {
    print "Only 1 line detected in the alignment of fake haplotypes from heterozygotes to be phased! Please check data format (opening the alignment in MEGA (http://www.megasoftware.net/) and exporting it as FASTA again may solve the problem; alternatively, there may be a problem with end-of-line characters, for instance if your file was manually transferred between computers using different operating systems (Linux, Macintosh or Windows; see http://en.wikipedia.org/wiki/Newline for details).";
    exit;
}
for ( my $i = 0 ; $i <= $#align3 ; $i++ ) {
    $align3[$i] =~ s/\R//g;
    if ( substr( $align3[$i], 0, 1 ) eq ';' ) {
        splice( @align3, $i, 1 );
        $i = $i - 1;
    }
}

#makes a two-column table
my @table3;
$j = -1;
for ( my $i = 0 ; $i <= $#align3 ; $i++ ) {
    if ( substr( $align3[$i], 0, 1 ) eq '>' ) {
        $j++;
        $table3[$j][0] = substr( $align3[$i], 1 );
        $table3[$j][1] = '';
    } else { $table3[$j][1] = $table3[$j][1] . $align3[$i] }
}

#removes spaces in the sequence column
for ( my $i = 0 ; $i <= $#table3 ; $i++ ) {
    $table3[$i][1] = join( '', ( split( ' ', $table3[$i][1] ) ) );
}

#sort sequences by alphabetical order
@table3 = sort { $a->[0] cmp $b->[0] } @table3;

#test table
for ( my $i = 0 ; $i < $#table3 ; $i++ ) {
    if ( $table3[$i][0] eq $table3[ $i + 1 ][0] ) {
        print "Repeat of name $table3[$i][0] encountered in alignment of fake haplotypes from heterozygotes to be phased.";
        $error_count++;
    }
}
if ( $#table3 % 2 == 0 ) {
    print "Uneven number of sequences in alignment of fake haplotypes from heterozygotes to be phased: please check data.";
    exit;
}
for ( my $i = 0 ; $i < $#table3 / 2 ; $i++ ) {
    my $indiv1 = $table3[ 2 * $i ][0];
    my $indiv2 = $table3[ 2 * $i + 1 ][0];
    chop($indiv1);
    chop($indiv2);
    chop($indiv1);
    chop($indiv2);
    if ( $indiv1 ne $indiv2 ) {
        print "Only one haplotype sequence found for individual $indiv1 (in the alignment of fake haplotypes from heterozygotes to be phased); please check data.";
        $error_count++;
    }
}

#test for unauthorized characters in sequences
for ( my $i = 0 ; $i <= $#table3 ; $i++ ) {
    my $control = $table3[$i][1];
    chomp($control);
    my @cont = split( '', $control );
    foreach my $r (@cont) {
        if ( $r ne '?' ) {
            if ( !grep( /$r/, @authorized_restricted ) ) {
                print "Unauthorized character state ($r) in $table3[$i][0] (in the alignment of fake haplotype pairs from heterozygotes to be phased).";
                $error_count++;
            }
        }
    }
}

#find longest sequence
for ( my $i = 0 ; $i <= $#table3 ; $i++ ) {
    my $l = length( $table3[$i][1] );
    if ( $l != $maxseqlength ) { $maxseqlength = $l; $error_count2++ }
}

#processing alignment 2
my @align2;
if ( defined($opt_3) ) {
    open( AL2, $opt_3 ) || die "Error: Cannot open input file $opt_3\n";
}
@align2 = <AL2>;

#remove all comments and endline characters
if ( $#align2 == 0 ) {
    print "Error: Only 1 line detected in 2seq.fas!\nPlease check data format (opening the alignment in MEGA (http://www.megasoftware.net/) and exporting it as FASTA again may solve the problem; alternatively, there may be a problem with end-of-line characters, for instance if your file was manually transferred between computers using different operating systems (Linux, Macintosh or Windows; see http://en.wikipedia.org/wiki/Newline for details).\n";
    exit;
}
chomp(@align2);
$/ = "\r";
chomp(@align2);
$/ = "\n";
for ( my $i = 0 ; $i <= $#align2 ; $i++ ) {
    if ( substr( $align2[$i], 0, 1 ) eq ';' ) {
        splice( @align2, $i, 1 );
        $i = $i - 1;
    }
}

#makes a two-column table
my @table2;
$j = -1;
for ( my $i = 0 ; $i <= $#align2 ; $i++ ) {
    if ( substr( $align2[$i], 0, 1 ) eq '>' ) {
        $j++;
        $table2[$j][0] = substr( $align2[$i], 1 );
        $table2[$j][1] = '';
    } else { $table2[$j][1] = $table2[$j][1] . $align2[$i] }
}

#removes spaces in the sequence column
for ( my $i = 0 ; $i <= $#table2 ; $i++ ) {
    $table2[$i][1] = join( '', ( split( ' ', $table2[$i][1] ) ) );
}

#sort sequences by alphabetical order
@table2 = sort { $a->[0] cmp $b->[0] } @table2;

#test table
for ( my $i = 0 ; $i < $#table2 ; $i++ ) {
    if ( $table2[$i][0] eq $table2[ $i + 1 ][0] ) {
        print "Error: Repeat of name $table2[$i][0] encountered in alignment of phased haplotypes (2seq.fas).\n";
        $error_count++;
    }
}
if ( $#table2 % 2 == 0 ) {
    print "Error: Uneven number of sequences in alignment of phased haplotypes (2seq.fas): please check data.\n";
    exit;
}
for ( my $i = 0 ; $i < $#table2 / 2 ; $i++ ) {
    my $indiv1 = $table2[ 2 * $i ][0];
    my $indiv2 = $table2[ 2 * $i + 1 ][0];
    chop($indiv1);
    chop($indiv2);
    chop($indiv1);
    chop($indiv2);
    if ( $indiv1 ne $indiv2 ) {
        print "Error: Only one haplotype sequence found for individual $indiv1 in 2seq.fas; please check data.\n";
        $error_count++;
    }
}

#test for unauthorized characters in sequences
for ( my $i = 0 ; $i <= $#table2 ; $i++ ) {
    my $control = $table2[$i][1];
    chomp($control);
    my @cont = split( '', $control );
    foreach my $r (@cont) {
        if ( $r ne '?' ) {
            if ( !grep( /$r/, @authorized ) ) {
                print "Error: Unknown character state ($r) in $table2[$i][0] (in 2seq.fas).\n";
                $error_count++;
            }
        }
    }
}

#find longest sequence
for ( my $i = 0 ; $i <= $#table2 ; $i++ ) {
    my $l = length( $table2[$i][1] );
    if ( $l > $maxseqlength ) { $maxseqlength = $l; $error_count2++ }
}

if ( $error_count2 > 1 ) {
    print "Warning: Not all input sequences have equal lengths, please check whether this is expected.\n";
    exit;
}
if ( $error_count > 0 ) { exit }

#editing sequences
#put all in caps
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) { $table1[$i][1] =~ s/([a-z])/\U$1/g }
for ( my $i = 0 ; $i <= $#table2 ; $i++ ) { $table2[$i][1] =~ s/([a-z])/\U$1/g }
for ( my $i = 0 ; $i <= $#table3 ; $i++ ) { $table3[$i][1] =~ s/([a-z])/\U$1/g }

#resolve double peaks in heterozygous sequences
my @table1a;
my @table1b;
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    $table1a[$i] = $table1[$i][1];
    $table1a[$i] =~ s/W/A/g;
    $table1a[$i] =~ s/S/C/g;
    $table1a[$i] =~ s/K/T/g;
    $table1a[$i] =~ s/M/A/g;
    $table1a[$i] =~ s/Y/C/g;
    $table1a[$i] =~ s/R/A/g;
    $table1b[$i] = $table1[$i][1];
    $table1b[$i] =~ s/W/T/g;
    $table1b[$i] =~ s/S/G/g;
    $table1b[$i] =~ s/K/G/g;
    $table1b[$i] =~ s/M/C/g;
    $table1b[$i] =~ s/Y/T/g;
    $table1b[$i] =~ s/R/G/g;
}

#make list of variable positions and list of multiallelic sites
my @varpos   = ();
my @multipos = ();
for ( my $i = 0 ; $i < $maxseqlength ; $i++ ) {
    my @bases = ();
    for ( $j = 0 ; $j <= $#table1a ; $j++ ) {
        my $comp = substr( $table1a[$j], $i, 1 );
        my $quotecomp = quotemeta($comp);
        if ( !grep( /$quotecomp/, @bases ) ) { push( @bases, $comp ) }
    }
    for ( $j = 0 ; $j <= $#table1b ; $j++ ) {
        my $comp = substr( $table1b[$j], $i, 1 );
        my $quotecomp = quotemeta($comp);
        if ( !grep( /$quotecomp/, @bases ) ) { push( @bases, $comp ) }
    }
    for ( $j = 0 ; $j <= $#table2 ; $j++ ) {
        my $comp = substr( $table2[$j][1], $i, 1 );
        my $quotecomp = quotemeta($comp);
        if ( !grep( /$quotecomp/, @bases ) ) { push( @bases, $comp ) }
    }
    for ( $j = 0 ; $j <= $#table3 ; $j++ ) {
        my $comp = substr( $table3[$j][1], $i, 1 );
        my $quotecomp = quotemeta($comp);
        if ( !grep( /$quotecomp/, @bases ) ) { push( @bases, $comp ) }
    }
    my $nbbases = $#bases + 1;
    if ( $nbbases > 1 ) { push( @varpos, $i ) }
    if ( grep( /N/,  @bases ) ) { $nbbases = $nbbases - 1 }
    if ( grep( /\?/, @bases ) ) { $nbbases = $nbbases - 1 }
    if ( $nbbases > 2 ) { push( @multipos, $i ) }
}
my $nbvarpos   = $#varpos + 1;
my $nbmultipos = $#multipos + 1;
if ( $nbvarpos == 0 ) {
    print "Error: Not a single variable position detected in dataset! Please check data.\n";
    exit;
}
else {
    print "There are $nbvarpos variable positions in your dataset, including $nbmultipos position(s) with more than two different states.\n\n";
}

#generating PHASE input file & final check for duplicate names

my $char;
my %code = ( 'A' => 1, 'C' => 2, 'G' => 3, 'T' => 4, '?' => '?', 'N' => '?', '-' => 0 );
if ( !open( F, "> $opt_p.inp" ) ) { die "Writing error: $!\n" }
my $nbindiv = 2 + $#table1 + $#table2 / 2 + $#table3 / 2;
print F "$nbindiv\n";
print F "$nbvarpos\n";
my $number;
my @namelist;
my @duplicatenames = ();
print F "P";

for ( my $i = 0 ; $i <= $#varpos ; $i++ ) {
    $number = 1 + $varpos[$i];
    print F " $number";
}
print F "\n";

for ( my $i = 0 ; $i <= $#varpos ; $i++ ) {
    if   ( grep( /^$varpos[$i]$/, @multipos ) ) { print F 'M ' }
    else                                        { print F 'S ' }
}
print F "\n";
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    print F "$table1[$i][0]\n";
    if ( grep( /^$table1[$i][0]$/, @namelist ) ) {
        if ( !grep( /^$table1[$i][0]$/, @duplicatenames ) ) {
            push( @duplicatenames, $table1[$i][0] );
        }
    }
    else { push( @namelist, $table1[$i][0] ) }
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table1a[$i], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        } else { print F "$code{$char} " }
    }
    print F "\n";
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table1b[$i], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        }
        else { print F "$code{$char} " }
    }
    print F "\n";
}
for ( my $i = 0 ; $i < $#table3 / 2 ; $i++ ) {
    my $indiv = $table3[ 2 * $i ][0];
    $indiv =~ s/[\012\015]//g;
    chop($indiv);
    print F "$indiv\n";
    if ( grep( /^$indiv$/, @namelist ) ) {
        if ( !grep( /^$indiv$/, @duplicatenames ) ) {
            push( @duplicatenames, $indiv );
        }
    }
    else { push( @namelist, $indiv ) }
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table3[ 2 * $i ][1], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        } else { print F "$code{$char} " }
    }
    print F "\n";
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table3[ 2 * $i + 1 ][1], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        } else { print F "$code{$char} " }
    }
    print F "\n";
}
for ( my $i = 0 ; $i < $#table2 / 2 ; $i++ ) {
    my $indiv = $table2[ 2 * $i ][0];
    $indiv =~ s/[\012\015]//g;
    chop($indiv);
    print F "$indiv\n";
    if ( grep( /^$indiv$/, @namelist ) ) {
        if ( !grep( /^$indiv$/, @duplicatenames ) ) {
            push( @duplicatenames, $indiv );
        }
    }
    else { push( @namelist, $indiv ) }
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table2[ 2 * $i ][1], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        } else { print F "$code{$char} " }
    }
    print F "\n";
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) {
        $char = substr( $table2[ 2 * $i + 1 ][1], $varpos[$j], 1 );
        if (    ( ( $char eq '?' ) or ( $char eq 'N' ) )
            and ( grep( /^$varpos[$j]$/, @multipos ) ) )
        {
            print F "-1 ";
        }
        else { print F "$code{$char} " }
    }
    print F "\n";
}

close F;

if ( $#duplicatenames != -1 ) {
    print "Some names are found in more than one of the input alignments: @duplicatenames; please check input data.\n";
    exit;
}

print "There are $nbvarpos variable positions in your dataset, including $nbmultipos position(s) with more than two different states.";

#for (my $i=0; $i<=($#align1/2); $i++) {print substr($align1[1+2*$i],-1,1)};

for ( my $i = 0 ; $i <= ( $#align1 / 2 ) ; $i++ ) {
    if (   ( substr( $align1[ 1 + 2 * $i ], 0, 1 ) eq '-' )
        or ( ( substr( $align1[ 1 + 2 * $i ], -1, 1 ) ) eq '-' ) )
    {
        $error_count3++;
    }
}
for ( my $i = 0 ; $i <= ( $#align2 / 2 ) ; $i++ ) {
    if ((substr( $align2[ 1 + 2 * $i ], 0, 1 ) eq '-') or ((substr( $align2[ 1 + 2 * $i ], -1, 1 )) eq '-')) {
        $error_count3++;
    }
}
for ( my $i = 0 ; $i <= ( $#align3 / 2 ) ; $i++ ) {
    if (   ( substr( $align3[ 1 + 2 * $i ], 0, 1 ) eq '-' )
        or ( ( substr( $align3[ 1 + 2 * $i ], -1, 1 ) ) eq '-' ) )
    {
        $error_count3++;
    }
}

if ( $error_count3 == 1 ) {
    print
"Warning: one of your sequences starts and/or ends with '-', is it a real indel or did you mean 'N' or '?' (missing data)?";
}
if ( $error_count3 > 1 ) {
    print "Warning: ", $error_count3,
" of your sequences start and/or end with '-', are these real indels or did you mean 'N' or '?' (missing data)?";
}

#generating known phases file
if ( !open( F, "> $opt_p.known" ) ) { die "Writing error: $!\n" }
for ( my $i = 0 ; $i <= $#table1 ; $i++ ) {
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) { print F "*" }
    print F "\n";
}
for ( my $i = 0 ; $i < $#table3 / 2 ; $i++ ) {
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) { print F "*" }
    print F "\n";
}
for ( my $i = 0 ; $i < $#table2 / 2 ; $i++ ) {
    for ( my $j = 0 ; $j < $nbvarpos ; $j++ ) { print F "0" }
    print F "\n";
}
close F;

#generating constant positions file
if ( !open( F, "> $opt_p.const" ) ) { die "Writing error: $!\n" }
my $seq = $table1[0][1];
unless ($seq) { $seq = $table3[0][1] }
my @template = split( '', $seq );
unless ($seq) { $seq = $table2[0][1] }
my @template = split( '', $seq );
foreach my $f (@varpos) { $template[$f] = '.' }
foreach my $f (@template) { print F $f }
close F;

if ( $#table2 < 0 ) {
    print "Since PHASE only accepts numbers and not letters for nucleotides at multistate characters, ? and N (missing information) have been replaced with ? or -1 (depending on whether the position displays two or more than two different nucleotides), - with 0, A with 1, C with 2, G with 3 and T with 4 in $opt_p.inp, the main PHASE input file).\n\n";
} else {
    print "Since PHASE only accepts numbers and not letters for nucleotides at multistate characters, ? and N (missing information) have been replaced with ? or -1 (depending on whether the position displays two or more than two different nucleotides), - with 0, A with 1, C with 2, G with 3 and T with 4 in $opt_p.inp, the main PHASE input file. A known phase file $opt_p.known has also been generated to tell PHASE which phases are already known and which ones are to infer.\n\n";
}

if ( $nbvarpos < $maxseqlength ) {
    print "In order to reduce PHASE running time, constant positions have been removed from the dataset. These constant positions have been stored in $opt_p.const interspersed with periods (.) representing variable positions.\n\n";
}
if ( $#table2 < 0 ) {
    if ( $nbmultipos == 0 ) {
        print "Suggested command syntax (PHASE v2.1):\nPHASE $opt_p.inp $opt_p.out\n(the result of the analysis will be stored in a series of files with names starting with '$opt_p.out').\n\n";
    } else {
        print "Suggested command syntax (PHASE v2.1):\nPHASE -d1 $opt_p.inp $opt_p.out\n(the result of the analysis will be stored in a series of files with names starting with '$opt_p.out').\n\n";
    }
} else {
    if ( $nbmultipos == 0 ) {
        print "Suggested command syntax (PHASE v2.1):\nPHASE -k$opt_p.known $opt_p.inp $opt_p.out\n(the result of the analysis will be stored in a series of files with names starting with '$opt_p.out').\n\n";
    } else {
        print "Suggested command syntax (PHASE v2.1):\nPHASE -d1 -k$opt_p.known $opt_p.inp $opt_p.out\n(the result of the analysis will be stored in a series of files with names starting with '$opt_p.out').\n\n";
    }
}

close AL1;
close AL2;
close AL3;


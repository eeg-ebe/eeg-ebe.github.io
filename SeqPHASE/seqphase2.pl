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

use warnings;
use strict;
use Getopt::Std;
print "\n";

print "SeqPHASE commmand-line version, Step 2: converting PHASE output files into FASTA alignments\n\n";

print "Reference:\nFlot, J.-F. (2010) SeqPHASE: a web tool for interconverting PHASE input/output files and FASTA sequence alignments\nMolecular Ecology Ressources 10 (1): 162-166\n\n";

print "Usage: perl seqphase2.pl -c <constant position file> -i <input=PHASE output file> -o <output=FASTA file name> [-r for reduced output] [-s for sorted output] \nThe constant position file (optional) was generated during Step 1 (without such file, the output FASTA will only contain the variable positions).\nInput=PHASE output file (compulsory) may be either .out or .out_pairs.\nOutput=FASTA file name (when not specified, default is 'phased.fasta'): if generated from an .out file, it will contain a list of phased haplotypes with 1-letter indetermination code letters (R, W, M, Y, S or K) at positions where phase certainty is inferior to a certain threshold (90% if PHASE default running options were used); if generated from an .out_pairs file, it will contain all possible haplotype pairs for each individual with their respective probabilities shown between parentheses.\nThe FASTA output may be reduced to show only posterior probabilities inferior to 1 and only one sequence per homozygote (-r switch) and/or be sorted alphabetically (-s switch).\n\n";

our ( $opt_c, $opt_i, $opt_o, $opt_r, $opt_s );

getopts('i:c:o:rs');

unless ( defined($opt_i) ) { print "No input file specified.\n"; exit }
unless ( defined($opt_o) ) { $opt_o = "phased.fasta" }

my %code = ( 1 => 'A', 2 => 'C', 3 => 'G', 4 => 'T', -1 => 'N', 0 => '-' );
my %supercode = ( 'A' => 1, 'T' => 2, 'G' => 4, 'C' => 8, 'R' => 5, 'Y' => 10, 'M' => 9, 'K' => 6, 'W' => 3, 'S' => 12, 'V' => 13, 'B' => 14, 'H' => 11, 'D' => 7, 'N' => 15 );
my %rev_supercode = ( 1  => 'A', 2  => 'T', 4  => 'G', 8  => 'C', 5  => 'R', 10 => 'Y', 9  => 'M', 3  => 'W', 12 => 'S', 6  => 'K', 13 => 'V', 14 => 'B', 11 => 'H', 7  => 'D', 15 => 'N' );

my $constant = "";
if ( defined($opt_c) ) {
    open( CONST, $opt_c ) || die "Error: Cannot open input file $opt_c\n";
    $constant = <CONST>;
}
chomp $constant;
my @constpos = split( '', $constant );
my $pointcount = 0;
foreach my $j (@constpos) {
    if ( $j eq '.' ) { $pointcount++ }
}

open( OUTPUT, $opt_i ) || die "Error: Cannot open input file $opt_i\n";
my @lignes = <OUTPUT>;
my $jmax;
my @table;

if ( !open( F, ">$opt_o" ) ) { die "Writing error: $!" }

if ( substr( $lignes[0], 0, 10 ) eq '**********' ) {
print "1111";
    #processing .out file and making table of sequences

    my $start = 0;
    my $stop  = 0;
    my $k     = 0;
    for ( my $i = 0 ; $i <= $#lignes ; $i++ ) {
        $lignes[$i] =~ s/[\012\015]//g;
        if ( $lignes[$i] eq "BEGIN BESTPAIRS1" ) { $start = $i }
        if ( $lignes[$i] eq "END BESTPAIRS1" )   { $stop  = $i }
    }

    for ( my $i = $start + 1 ; $i < $stop ; $i++ ) {
        my $ligne;
        my @t;
        my @u;
        my @v;
        my @r;
        my @s;
        my $indiv;
        my @ubrackets;
        my @vbrackets;
        my @parentheses;
        my $base;
        $ligne = $lignes[$i];
        @t     = split( ' ', $ligne );
        $indiv = $t[1];
        $i++;
        $ligne = $lignes[$i];
        @u = split( ' ', $ligne );

        if ($constant) {
            if ( $#u != $pointcount - 1 ) {
                print "Error: The $opt_c and $opt_i files do not match; please check input data.\n";
                close F;
                exit;
            }
        }
        $i++;
        $ligne = $lignes[$i];
        @v = split( ' ', $ligne );
        if ($constant) {
            if ( $#v != $pointcount - 1 ) {
                print "Error: The $opt_c and $opt_i files do not match; please check input data.\n";
                close F;
                exit;
            }
        }

        for ( my $j = 0 ; $j <= $#u ; $j++ ) {
            @r = split( '', $u[$j] );
            @s = split( '', $v[$j] );
            if ( $r[0] eq "[" ) { push( @ubrackets,   $j ) }
            if ( $r[0] eq "(" ) { push( @parentheses, $j ) }
            if ( $s[0] eq "[" ) { push( @vbrackets,   $j ) }
        }
        for ( my $j = 0 ; $j <= $#u ; $j++ ) {
            $u[$j] =~ s/[\[\]\(\)]//g;
            $v[$j] =~ s/[\[\]\(\)]//g;
        }
        for ( my $j = 0 ; $j <= $#u ; $j++ ) {
            $u[$j] = $code{ $u[$j] };
            $v[$j] = $code{ $v[$j] };
        }

        foreach my $j (@parentheses) {
            $base =
              $rev_supercode{ $supercode{ $u[$j] } + $supercode{ $v[$j] } };
            $u[$j] = $base;
            $v[$j] = $base;
        }
        foreach my $j (@ubrackets) { $u[$j] = 'N' }
        foreach my $j (@vbrackets) { $v[$j] = 'N' }

        $table[ 2 * $k ][0] = $indiv . 'a';
        $table[ 2 * $k ][1] = '';
        if ($constant) {
            for ( my $j = 0 ; $j <= $#constpos ; $j++ ) {
                if ( $constpos[$j] eq '.' ) {
                    $table[ 2 * $k ][1] = $table[ 2 * $k ][1] . shift(@u);
                }
                else {
                    $table[ 2 * $k ][1] = $table[ 2 * $k ][1] . $constpos[$j];
                }
            }
        }
        else {
            for ( my $j = 0 ; $j <= $#u ; $j++ ) {
                $table[ 2 * $k ][1] = $table[ 2 * $k ][1] . $u[$j];
            }
        }

        $table[ 1 + 2 * $k ][0] = $indiv . 'b';
        $table[ 1 + 2 * $k ][1] = '';
        if ($constant) {
            for ( my $j = 0 ; $j <= $#constpos ; $j++ ) {
                if ( $constpos[$j] eq '.' ) {
                    $table[ 1 + 2 * $k ][1] =
                      $table[ 1 + 2 * $k ][1] . shift(@v);
                }
                else {
                    $table[ 1 + 2 * $k ][1] =
                      $table[ 1 + 2 * $k ][1] . $constpos[$j];
                }
            }
        }
        else {
            for ( my $j = 0 ; $j <= $#v ; $j++ ) {
                $table[ 1 + 2 * $k ][1] = $table[ 1 + 2 * $k ][1] . $v[$j];
            }
        }

        $k++;
    }

    print "A FASTA alignment of phased haplotypes";
    if ( defined($opt_s) ) { print " (sorted alphabetically)" }
    print " has been saved under the name '$opt_o'. In this file, each of the two haplotypes inferred from an individual's sequence were given the name of that individual followed by a or b. Positions where phase certainty was inferior to a certain threshold (90\% using PHASE default running options; this probability threshold can be modified by running PHASE using the -p and -q options, see PHASE documentation) were indicated with 1-letter indetermination codes (R, W, M, Y, S or K).\n\n";

}

else {
print "AAA";
    if ( substr( $lignes[0], 0, 3 ) eq 'IND' ) {

        #processing .out_pairs file and making table of sequences

        my $indiv   = 'null';
        my $base    = 'null';
        my $counter = 0;
        my $k       = 0;

        chomp(@lignes);
        $/ = "\r";
        chomp(@lignes);
        $/ = "\n";

        foreach my $ligne (@lignes) {
print "YYY";
            $ligne =~ s/ -[0-9]* / ? /g;
            my @s = split( ' ', $ligne );

            if ( $s[0] eq 'IND:' ) { $indiv = $s[1]; $counter = 0 }
            else {
                $counter++;
                my @t = split( ' , ', $ligne );
                if ( defined($opt_r) ) {
                    if ( $t[2] == '1.00' ) {
                        $table[ 2 * $k ][0] = $indiv . 'a';
                    } else {
                        $table[ 2 * $k ][0] = $indiv . '-' . $counter . 'a (' . $t[2] . ')';
                    }
                } else {
                    $table[ 2 * $k ][0] =
                    $indiv . 'a_' . $counter . '(' . $t[2] . ')';
                }
                $table[ 2 * $k ][1] = '';

                $t[0] =~ s/\s+//g;
                my @u = split( '', $t[0] );
                for ( my $j = 0 ; $j <= $#u ; $j++ ) {
                    $u[$j] = $code{ $u[$j] };
                }

                if ($constant) {
                    if ( $#u != $pointcount - 1 ) {
                        print "Error: The $opt_c and $opt_i files do not match; please check input data.\n";
                        close F;
                        exit;
                    }
                }

                if ($constant) {
                    for ( my $j = 0 ; $j <= $#constpos ; $j++ ) {
                        if ( $constpos[$j] eq '.' ) {
                            $table[ 2 * $k ][1] =
                              $table[ 2 * $k ][1] . shift(@u);
                        }
                        else {
                            $table[ 2 * $k ][1] =
                              $table[ 2 * $k ][1] . $constpos[$j];
                        }
                    }
                }
                else {
                    for ( my $j = 0 ; $j <= $#u ; $j++ ) {
                        $table[ 2 * $k ][1] = $table[ 2 * $k ][1] . $u[$j];
                    }
                }
print "XXX";
                if ( defined($opt_r) ) {
print $t[2];
                    if ( $t[2] == '1.00' ) {
                        $table[ 1 + 2 * $k ][0] = $indiv . 'b';
                    }
                    else {
                        $table[ 1 + 2 * $k ][0] =
                          $indiv . '-' . $counter . 'b (' . $t[2] . ')';
                    }
                }
                else {
                    $table[ 1 + 2 * $k ][0] =
                      $indiv . 'b_' . $counter . '(' . $t[2] . ')';
                }
                $table[ 1 + 2 * $k ][1] = '';

                $t[1] =~ s/\s+//g;
                my @v = split( '', $t[1] );
                for ( my $j = 0 ; $j <= $#v ; $j++ ) {
                    $v[$j] = $code{ $v[$j] };
                }

                if ($constant) {
                    if ( $#v != $pointcount - 1 ) {
                        print "Error: The $opt_c and $opt_i do not match; please check input data.\n";
                        close F;
                        exit;
                    }
                }

                if ($constant) {
                    for ( my $j = 0 ; $j <= $#constpos ; $j++ ) {
                        if ( $constpos[$j] eq '.' ) {
                            $table[ 1 + 2 * $k ][1] =
                              $table[ 1 + 2 * $k ][1] . shift(@v);
                        }
                        else {
                            $table[ 1 + 2 * $k ][1] =
                              $table[ 1 + 2 * $k ][1] . $constpos[$j];
                        }
                    }
                }
                else {
                    for ( my $j = 0 ; $j <= $#u ; $j++ ) {
                        $table[ 1 + 2 * $k ][1] =
                          $table[ 1 + 2 * $k ][1] . $v[$j];
                    }
                }

                $k++;
            }
        }

        print "A FASTA alignments of phased haplotypes pairs";
        if ( defined($opt_s) ) { print " (sorted alphabetically)" }
        print " has been saved under $opt_o. In this file, the posterior probability of each haplotype is shown after its name";
        if ( defined($opt_r) ) { print " unless it is equal to 1" }
        print ". In case there are several alternative haplotype reconstructions, then all possible haplotypes are listed (hence, no 1-letter indermination code is used).\n\n";

    }

    else {
        print "Input file not recognized (this is neither a .out nor a .out_pairs file generated by PHASE)";
        exit;
    }
}

#fixing homozyogtes
my $i = 0;
if ( defined($opt_r) ) {
    while ( $i < $#table ) {
        if ( $table[$i][1] eq $table[ $i + 1 ][1] ) {
            splice( @table, $i, 1 );
            chop( $table[$i][0] );
        }
        else { $i++ }
        $i++;
    }
}

#sorting sequences in alphabetical order
if ( defined($opt_s) ) {
    @table = sort { $a->[0] cmp $b->[0] } @table;
}

#writing output file
for ( my $i = 0 ; $i <= $#table ; $i++ ) {
    print F ">$table[$i][0]\n";
    print F "$table[$i][1]\n";
}

close F;


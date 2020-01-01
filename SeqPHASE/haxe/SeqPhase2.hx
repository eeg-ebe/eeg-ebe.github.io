/**
 * Copyright (c) 2009-2019, Jean-Francois Flot <http://dx.doi.org/10.1111/j.1755-0998.2009.02732.x>
 * Translated to HaXe by Yann Spoeri
 *
 * Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is
 * hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
 * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
 * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

import haxe.ds.ArraySort;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
#if sys
import sys.io.File;
#end

/**
 * This class principally contains the content of SeqPhase2.pl. Since Haxe expects you to have classes
 * but the original python script doesn't contain any, there are some changes in structure and code
 * ordering. These changes are also needed because the code needs to get converted into JavaScript code
 * later on and reading / storing files works asynchronly in JavaScript (which is quite different to the
 * reading mechanisms of Perl).
 */
class SeqPhase2 {

    private static var code:IntMap<String> = [
        1  => 'A',
        2  => 'C',
        3  => 'G',
        4  => 'T',
        -1 => 'N',
        0  => '-'
    ];

    private static var supercode:StringMap<Int> = [
        'A' => 1,
        'T' => 2,
        'G' => 4,
        'C' => 8,
        'R' => 5,
        'Y' => 10,
        'M' => 9,
        'K' => 6,
        'W' => 3,
        'S' => 12,
        'V' => 13,
        'B' => 14,
        'H' => 11,
        'D' => 7,
        'N' => 15
    ];

    private static var revSupercode:IntMap<String> = [
        1  => 'A',
        2  => 'T',
        4  => 'G',
        8  => 'C',
        5  => 'R',
        10 => 'Y',
        9  => 'M',
        3  => 'W',
        12 => 'S',
        6  => 'K',
        13 => 'V',
        14 => 'B',
        11 => 'H',
        7  => 'D',
        15 => 'N'
    ];

    public static function removePossibleLineEndingR(line:String):String {
        if (line.length >= 1) {
            if (line.charAt(0) == "\r") {
                line = line.substr(1);
            }
            if (line.charAt(line.length - 1) == "\r") {
                line = line.substr(0, line.length - 1);
            }
        }
        return StringTools.trim(line);
    }

    public static function genConstString(length:Int):String {
        var result:List<String> = new List<String>();
        for (i in 0...length) {
            result.add(".");
        }
        return result.join("");
    }

    public static function nSplit(s:String):List<String> {
        var result:List<String> = new List<String>();
        for (i in 0...s.length) {
            var char:String = s.charAt(i);
            if (char == " ") continue;
            result.add(char);
        }
        return result;
    }

    public static function nrsToSeq(nrs:String, const:String):String {
        var nrs:List<String> = nSplit(nrs); //nrs.split(""); Array->List
        if (const == null || const == "") {
            const = genConstString(nrs.length);
        }
        var codeS:List<String> = new List<String>();
        for (part in nrs) {
            codeS.add(code.get(Std.parseInt(part)));
        }
        var doesNotMatch:Bool = false;
        var result:List<String> = new List<String>();
        for (i in 0...const.length) {
            var chr:String = const.charAt(i);
            if (chr == ".") {
                var nextCodeS:Null<String> = codeS.pop();
                if (nextCodeS == null) {
                    doesNotMatch = true;
                    break;
                }
                result.add(nextCodeS);
            } else {
                result.add(chr);
            }
        }
        if (doesNotMatch || codeS.length != 0) {
            throw "Error: The data in the const and in the input file do not match; please check input data. (" + doesNotMatch + ", " + codeS.length + ")";
        }
        return result.join("");
    }

    public static function parsePairFile(fileContent:String, const:String=""):Individuals {
        var result:Individuals = new Individuals();
        result.setOutFile(false);
        var lineNo:Int = 0;
        var currentIndividualName:String = "";
        var index:Int = 0;
        for (line in fileContent.split("\n")) {
            line = removePossibleLineEndingR(line);
            lineNo++;
            if (line != "") {
                if (line.substr(0, 5) == "IND: ") {
                    currentIndividualName = line.substr(5);
                    index = 1;
                } else {
                    var parts:Array<String> = line.split(" , ");
                    if (parts.length != 3) {
                        throw "Please check line " + lineNo + " in the input file!";
                    }
                    var seq1:String = nrsToSeq(parts[0], const);
                    var seq2:String = nrsToSeq(parts[1], const);
                    var probability:Float = Std.parseFloat(parts[2]);
                    var ind:Individual = new Individual(currentIndividualName, seq1, seq2, index++, probability);
                    result.addIndividual(ind);
                }
            }
        }
        return result;
    }

    public static function stripBraces(c:String):String {
        if (c.charAt(0) == "(") {
            c = c.substr(1);
        }
        if (c.charAt(c.length - 1) == ")") {
            c = c.substr(0, c.length - 1);
        }
        return c;
    }

    public static function getSumCode(c1:String, c2:String):String {
        c1 = stripBraces(c1);
        c2 = stripBraces(c2);
        var code1:Int = Std.parseInt(c1);
        var code2:Int = Std.parseInt(c2);
        var code1S:String = code.get(code1);
        var code2S:String = code.get(code2);
        var codeSum:Int = supercode.get(code1S) + supercode.get(code2S);
        return revSupercode.get(codeSum);
    }

    public static function processLines(indName:String, seqLine1:String, seqLine2:String, const:String, lineNo:Int):List<Individual> {
        var result:List<Individual> = new List<Individual>();
        var r = ~/ +/g;
        var pLine1:Array<String> = r.split(seqLine1);
        var pLine2:Array<String> = r.split(seqLine2);
        if (pLine1.length != pLine2.length) {
            throw "Error: Sequences have different lengths. Please check sequences of individual " + indName + " (line " + (lineNo-2) + "ff.) in input file.";
        }
        if (const == null || const == "") {
            const = genConstString(pLine1.length);
        }
        var r1:List<String> = new List<String>();
        var r2:List<String> = new List<String>();
        for (i in 0...pLine1.length) {
            var c1:String = pLine1[i];
            var c2:String = pLine2[i];
            var processed1:Bool = false;
            var processed2:Bool = false;
            // [] => N
            if (c1.charAt(0) == "[") {
                r1.add("N");
                r2.add("N");
                processed1 = true;
                processed2 = true;
            }
            // () => sum
            if (c1.charAt(0) == "(") {
                r1.add(getSumCode(c1, c2));
                processed1 = true;
            }
            if (c2.charAt(0) == "(") {
                r2.add(getSumCode(c2, c1));
                processed2 = true;
            }
            if (!processed1) {
                r1.add(code.get(Std.parseInt(c1)));
            }
            if (!processed2) {
                r2.add(code.get(Std.parseInt(c2)));
            }
        }
        var seq1:List<String> = new List<String>();
        var seq2:List<String> = new List<String>();
        var doesNotMatch:Bool = false;
        for (i in 0...const.length) {
            var chr:String = const.charAt(i);
            if (chr == ".") {
                var r1S:Null<String> = r1.pop();
                var r2S:Null<String> = r2.pop();
                if (r1S == null || r2S == null) {
                    doesNotMatch = true;
                    break;
                }
                seq1.add(r1S);
                seq2.add(r2S);
            } else {
                seq1.add(chr);
                seq2.add(chr);
            }
        }
        if (doesNotMatch || r1.length != 0 || r2.length != 0) {
            throw "Error: The data in the const and in the input file do not match; please check input data. (" + doesNotMatch + ", " + r1.length + ", " + r2.length + ")";
        }
        var ind:Individual = new Individual(indName, seq1.join(""), seq2.join(""), -1, 1.0);
        result.add(ind);
        return result;
    }

    public static function parseOutFile(fileContent:String, const:String=""):Individuals {
        var result:Individuals = new Individuals();
        result.setOutFile(true);
        var lineNo:Int = 0;
        var currentIndividualName:Null<String> = null;
        var currentSeq1:Null<String> = null;
        var currentSeq2:Null<String> = null;
        var index:Int = 0;
        var seenBeginBestPairs1:Bool = false;
        for (line in fileContent.split("\n")) {
            line = removePossibleLineEndingR(line);
            lineNo++;
            if (line == "BEGIN BESTPAIRS1") {
                seenBeginBestPairs1 = true;
            } else if (line == "END BESTPAIRS1") {
                break;
            } else if(seenBeginBestPairs1) {
                if (currentIndividualName == null) {
                    currentIndividualName = line.split(" ")[1];
                } else if (currentSeq1 == null) {
                    currentSeq1 = line;
                } else {
                    currentSeq2 = line;
                    // process lines
                    for (ind in processLines(currentIndividualName, currentSeq1, currentSeq2, const, lineNo)) {
                        result.addIndividual(ind);
                    }
                    // for next
                    currentIndividualName = null;
                    currentSeq1 = null;
                }
            }
        }
        return result;
    }

    public static function parse(fileContent:String, const:String=""):Individuals {
        if (fileContent.substr(0, 10) == "**********") {
            return parseOutFile(fileContent, const);
        } else if (fileContent.substr(0, 5) == "IND: ") {
            return parsePairFile(fileContent, const);
        }
        throw "Input file not recognized (this is neither a .out nor a .out_pairs file generated by PHASE)";
    }

    public static function main() {
        #if sys
        Sys.stderr().writeString("SeqPHASE commmand-line version, Step 2: converting PHASE output files into FASTA alignments\n\n");
        Sys.stderr().writeString("Reference:\nFlot, J.-F. (2010) SeqPHASE: a web tool for interconverting PHASE input/output files and FASTA sequence alignments\nMolecular Ecology Ressources 10 (1): 162-166\n\n");
        Sys.stderr().writeString("Usage: perl seqphase2.pl -c <constant position file> -i <input=PHASE output file> -o <output=FASTA file name> [-r for reduced output] [-s for sorted output] \nThe constant position file (optional) was generated during Step 1 (without such file, the output FASTA will only contain the variable positions).\nInput=PHASE output file (compulsory) may be either .out or .out_pairs.\nOutput=FASTA file name (when not specified, default is 'phased.fasta'): if generated from an .out file, it will contain a list of phased haplotypes with 1-letter indetermination code letters (R, W, M, Y, S or K) at positions where phase certainty is inferior to a certain threshold (90% if PHASE default running options were used); if generated from an .out_pairs file, it will contain all possible haplotype pairs for each individual with their respective probabilities shown between parentheses.\nThe FASTA output may be reduced to show only posterior probabilities inferior to 1 and only one sequence per homozygote (-r switch) and/or be sorted alphabetically (-s switch).\n\n");

        var myArgs:Array<String> = Sys.args();
        var fileContent:Null<String> = null;
        var outfile:Null<String> = "phased.fasta";
        var constFileContent:String = "";
        var reduce:Bool = false;
        var sort:Bool = false;
        var i:Int = 0;
        while (i < myArgs.length) {
            var current:String = myArgs[i];
            if (current == "-r") {
                reduce = true;
            } else if (current == "-s") {
                sort = true;
            } else if (current == "-i") {
                fileContent = sys.io.File.getContent(myArgs[++i]);
            } else if (current == "-o") {
                outfile = myArgs[++i];
            } else if(current == "-c") {
                constFileContent = sys.io.File.getContent(myArgs[++i]);
            } else {
                Sys.stderr().writeString("Error: Unknown commandline option " + current + "\n");
                Sys.exit(1);
            }
            ++i;
        }

        if (fileContent == null) {
            Sys.stderr().writeString("No input file specified.\n");
            Sys.exit(1);
        }

        var result:Individuals = parse(fileContent, constFileContent);
        var resultFileContent:String = result.getFasta(reduce, sort);

        var fout = File.write(outfile, false);
        fout.writeString(resultFileContent);
        fout.close();

        Sys.stderr().writeString("A FASTA alignments of phased haplotypes pairs");
        if(sort) {
            Sys.stderr().writeString(" (sorted alphabetically)");
        }
        Sys.stderr().writeString(" has been saved under " + outfile + ".\n");

        Sys.exit(0);
        #end
    }

}

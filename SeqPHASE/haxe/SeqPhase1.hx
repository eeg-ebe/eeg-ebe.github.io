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

import haxe.ds.IntMap;
import haxe.ds.StringMap;
#if sys
import sys.io.File;
#end

/**
 * This class principally contains the content of SeqPhase1.pl. Since Haxe expects you to have classes
 * but the original python script doesn't contain any, there are some changes in structure and code
 * ordering. These changes are also needed because the code needs to get converted into JavaScript code
 * later on and reading / storing files works asynchronly in JavaScript (which is quite different to the
 * reading mechanisms of Perl).
 */
class SeqPhase1 {

    private static var map1:StringMap<String> = [
        "W" => "A", "S" => "C", "K" => "T", "M" => "A", "Y" => "C", "R" => "A"
    ];
    private static var map2:StringMap<String> = [
        "W" => "T", "S" => "G", "K" => "G", "M" => "C", "Y" => "T", "R" => "G"
    ];

    private static var code:StringMap<String> = [
        "A" => "1", "C" => "2", "G" => "3", "T" => "4", "?" => "?", "N" => "?", "-" => "0"
    ];

    public static function doIt(align1:Null<String>, align2:Null<String>, align3:Null<String>):SeqPhase1Result {
        SeqPhase1Result.instance().clear();
        // parse
        var al1:FastaAlignmentParser = new FastaAlignmentParser(align1, false, 1);
        var al2:FastaAlignmentParser = new FastaAlignmentParser(align2, true, 2);
        var al3:FastaAlignmentParser = new FastaAlignmentParser(align3, true, 3);
        // check sequence length
        var expectedLength:Int = (al1.getSeqLength() > al2.getSeqLength()) ? al1.getSeqLength() : al2.getSeqLength();
        expectedLength = (expectedLength > al3.getSeqLength()) ? expectedLength : al3.getSeqLength();
        var diffLength:Bool = false;
        if(al1.getSeqLength() != -1 && al1.getSeqLength() != expectedLength) {
            diffLength = true;
        }
        if(al2.getSeqLength() != -1 && al2.getSeqLength() != expectedLength) {
            diffLength = true;
        }
        if(al3.getSeqLength() != -1 && al3.getSeqLength() != expectedLength) {
            diffLength = true;
        }
        if (diffLength) {
            SeqPhase1Result.instance().addGeneralError("Not all input sequences have equal lengths, please check whether this is expected.");
        } else if(expectedLength == -1 || expectedLength == 0) {
            SeqPhase1Result.instance().addGeneralError("It seems that all given sequences are empty ...");
        }
        // error exit?
        if(SeqPhase1Result.instance().hasErrors()) {
            return SeqPhase1Result.instance();
        }
        // split al1
        var al1a:List<Entry> = new List<Entry>();
        var al1b:List<Entry> = new List<Entry>();
        for (entry in al1.getSequences()) {
            var seq1a:List<String> = new List<String>();
            var seq1b:List<String> = new List<String>();
            for(i in 0...entry.getSeq().length) {
                var c:String = entry.getSeq().charAt(i);
                if(map1.exists(c)) {
                    seq1a.add(map1.get(c));
                    seq1b.add(map2.get(c));
                } else {
                    seq1a.add(c);
                    seq1b.add(c);
                }
            }
            al1a.add(new Entry(entry.getLineNo(), entry.getName(), seq1a.join("")));
            al1b.add(new Entry(entry.getLineNo(), entry.getName(), seq1b.join("")));
        }
        // list of multiallelic sites
        var varpos:List<Int> = new List<Int>();
        var multipos:List<Int> = new List<Int>();
        var multiposMap:IntMap<Bool> = new IntMap<Bool>();
        var constFileContent:List<String> = new List<String>();
        for (i in 0...expectedLength) {
            var m:StringMap<Bool> = new StringMap<Bool>();
            for (entry in al1a) {
                m.set(entry.getSeq().charAt(i), false);
            }
            for (entry in al1b) {
                m.set(entry.getSeq().charAt(i), false);
            }
            for (entry in al2.getSequences()) {
                m.set(entry.getSeq().charAt(i), false);
            }
            for (entry in al3.getSequences()) {
                m.set(entry.getSeq().charAt(i), false);
            }
            var mapLen:Int = 0;
            var mapLenWithoutNs:Int = 0;
            var lastKey:String;
            for(key in m.keys()) {
                lastKey = key;
                mapLen++;
                if(key != "N") {
                    mapLenWithoutNs++;
                }
            }
            if(mapLen == 0) { // This should never happen
                SeqPhase1Result.instance().addGeneralError("Bug detected: There seems to be a bug in this implementation of SeqPHASE. Please contact the author so that they can fix this bug.");
                constFileContent.add("X");
            } else if(mapLen == 1) {
                if(lastKey == "N") {
                    SeqPhase1Result.instance().addGeneralWarn("Found only N/? s at position " + (i + 1) + ".");
                } else if(lastKey == "-") {
                    SeqPhase1Result.instance().addGeneralWarn("Found only -'s at position " + (i + 1) + ". This may indicate an alignment problem. Consider to recheck your input data!");
                }
                constFileContent.add(lastKey);
            } else {
                constFileContent.add(".");
                varpos.add(i);
                if(mapLenWithoutNs > 2) {
                    multipos.add(i);
                    multiposMap.set(i, true);
                } else {
                    multiposMap.set(i, false);
                }
            }
        }
        if(varpos.length == 0) {
            SeqPhase1Result.instance().addGeneralError("Not a single variable position detected in dataset! Please check data.");
        } else {
            SeqPhase1Result.instance().addNote("There are " + (varpos.length) + " variable positions in your dataset, including " + (multipos.length) + " position(s) with more than two different states.");
        }
        // create const files
        SeqPhase1Result.instance().setConstFile(constFileContent.join(""));
        // create inp file
        var lines:List<String> = new List<String>();
        lines.add("" + Std.int(al1a.length + al2.getSequences().length / 2 + al3.getSequences().length / 2));
        lines.add("" + (varpos.length));
        var l1:List<String> = new List<String>();
        var l2:List<String> = new List<String>();
        for(pos in varpos) {
            l1.add("" + (pos + 1));
            if(multiposMap.get(pos)) {
                l2.add("M");
            } else {
                l2.add("S");
            }
        }
        lines.add("P " + l1.join(" "));
        lines.add(l2.join(" "));
        var it1:Iterator<Entry> = al1a.iterator();
        var it2:Iterator<Entry> = al1b.iterator();
        while (it1.hasNext()) {
            var e1:Entry = it1.next();
            var e2:Entry = it2.next();
            lines.add(e1.getName());
            var line1:List<String> = new List<String>();
            var line2:List<String> = new List<String>();
            for(i in 0...e1.getSeq().length) {
                var char:String = e1.getSeq().charAt(i);
                if(char == "N" && multiposMap.exists(i)) {
                    line1.add("-1");
                } else {
                    line1.add(code.get(char));
                }
            }
            for(i in 0...e2.getSeq().length) {
                var char:String = e2.getSeq().charAt(i);
                if(char == "N" && multiposMap.exists(i)) {
                    line2.add("-1");
                } else {
                    line2.add(code.get(char));
                }
            }
            lines.add(line1.join(" "));
            lines.add(line2.join(" "));
        }
        var isOdd:Bool = false;
        for (entry in al2.getSequences()) {
            isOdd = !isOdd;
            if(isOdd) {
                var name:String = entry.getName();
                lines.add(name.substr(0, name.length - 1));
            }
            var line:List<String> = new List<String>();
            for(i in 0...entry.getSeq().length) {
                var char:String = entry.getSeq().charAt(i);
                if(char == "N" && multiposMap.exists(i)) {
                    line.add("-1");
                } else {
                    line.add(code.get(char));
                }
            }
            lines.add(line.join(" "));
        }
        isOdd = false;
        for (entry in al3.getSequences()) {
            isOdd = !isOdd;
            if(isOdd) {
                var name:String = entry.getName();
                lines.add(name.substr(0, name.length - 1));
            }
            var line:List<String> = new List<String>();
            for(i in 0...entry.getSeq().length) {
                var char:String = entry.getSeq().charAt(i);
                if(char == "N" && multiposMap.exists(i)) {
                    line.add("-1");
                } else {
                    line.add(code.get(char));
                }
            }
            lines.add(line.join(" "));
        }
        SeqPhase1Result.instance().setInpFile(lines.join("\n"));
        // create known file
        var knownLines:List<String> = new List<String>();
        var nStr:String = makeStr("*", varpos.length);
        var oStr:String = makeStr("0", varpos.length);
        for(i in 0...al1.getSequences().length) {
            knownLines.add(nStr);
        }
        var lll1:Int = Std.int(al2.getSequences().length / 2);
        for(i in 0...lll1) {
            knownLines.add(nStr);
        }
        var lll2:Int = Std.int(al3.getSequences().length / 2);
        for(i in 0...lll2) {
            knownLines.add(oStr);
        }
        SeqPhase1Result.instance().setKnownFile(knownLines.join("\n"));
        // setSuggestedPhaseCommand
        if(al3.getSequences().length == 0) {
            if(multipos.length == 0) {
                SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE seqphase.inp seqphase.out");
            } else {
                SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -d1 seqphase.inp seqphase.out");
            }
        } else {
            if(multipos.length == 0) {
                SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -kseqphase.known seqphase.inp seqphase.out");
            } else {
                SeqPhase1Result.instance().setSuggestedPhaseCommand("PHASE -d1 -kseqphase.known seqphase.inp seqphase.out");
            }
        }
        return SeqPhase1Result.instance();
    }

    public static inline function makeStr(c:String, i:Int) {
        var result:List<String> = new List<String>();
        for(nnn in 0...i) {
            result.add(c);
        }
        return result.join("");
    }

    public static function main() {
        #if sys
        Sys.stderr().writeString("SeqPHASE command-line version, Step 1: generating PHASE input files from FASTA alignments\n\n");
        Sys.stderr().writeString("Reference:\nFlot, J.-F. (2010) SeqPHASE: a web tool for interconverting PHASE input/output files and FASTA sequence alignments\nMolecular Ecology Ressources 10 (1): 162-166\n\n");
        Sys.stderr().writeString("Usage: perl seqphase1.pl -1 <first type of input file> -2 <second type of input file> -3 <third type of input file> -p <prefix>\nFirst type of input file = FASTA alignment of sequences from homozygous individuals and from heterozygotes to be phased (1 sequence per individual).\nSecond type of input file = FASTA alignment of alignment of fake haplotypes from heterozygotes to be phased (2 sequences per individual).\nThird type of input file (optional)= FASTA alignment of known haplotypes of previously phased heterozygotes (2 sequences per individual).\nPrefix for output files is optional, default prefix is 'phase'.\n\n");

        var myArgs:Array<String> = Sys.args();
        var file1:Null<String> = null;
        var file2:Null<String> = null;
        var file3:Null<String> = null;
        var prefix:Null<String> = "phase";
        var i:Int = 0;
        while (i < myArgs.length) {
            var current:String = myArgs[i];
            if (current == "-1") {
                file1 = sys.io.File.getContent(myArgs[++i]);
            } else if (current == "-2") {
                file2 = sys.io.File.getContent(myArgs[++i]);
            } else if(current == "-3") {
                file3 = sys.io.File.getContent(myArgs[++i]);
            } else if(current == "-p") {
                prefix = myArgs[++i];
            } else {
                Sys.stderr().writeString("Error: Unknown commandline option " + current + "\n");
                Sys.exit(1);
            }
            ++i;
        }

        if(file1 == null && file2 == null) {
            Sys.stderr().writeString("There is no input file to be phased!\n");
            Sys.exit(1);
        }

        // do it
        var result:SeqPhase1Result = doIt(file1, file2, file3);
        
        // output errors and warnings
        if (result.hasAlign1Errors()) {
            Sys.stderr().writeString("The following errors occured while processing the -1 file:\n");
            for(s in result.getAlign1Errors()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }
        if (result.hasAlign1Warn()) {
            Sys.stderr().writeString("The following warnings occured while processing the -1 file:\n");
            for(s in result.getAlign1Warn()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }

        if (result.hasAlign2Errors()) {
            Sys.stderr().writeString("The following errors occured while processing the -2 file:\n");
            for(s in result.getAlign2Errors()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }
        if (result.hasAlign2Warn()) {
            Sys.stderr().writeString("The following warnings occured while processing the -2 file:\n");
            for(s in result.getAlign2Warn()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }

        if (result.hasAlign3Errors()) {
            Sys.stderr().writeString("The following errors occured while processing the -3 file:\n");
            for(s in result.getAlign3Errors()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }
        if (result.hasAlign3Warn()) {
            Sys.stderr().writeString("The following warnings occured while processing the -3 file:\n");
            for(s in result.getAlign3Warn()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }

        if (result.hasGeneralErrors()) {
            Sys.stderr().writeString("The following errors occured:\n");
            for(s in result.getGeneralErrors()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }
        if (result.hasGeneralWarn()) {
            Sys.stderr().writeString("The following warnings occured:\n");
            for(s in result.getGeneralWarn()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }
        if (result.hasNotes()) {
            for(s in result.getNotes()) {
                Sys.stderr().writeString(s);
                Sys.stderr().writeString("\n");
            }
        }

        if(result.hasInpFile()) {
            var fout = File.write(prefix + ".inp", false);
            fout.writeString(result.getInpFile());
            fout.close();
            Sys.stderr().writeString("Since PHASE only accepts numbers and not letters for nucleotides at multistate characters, ? and N (missing information) have been replaced with ? or -1 (depending on whether the position displays two or more than two different nucleotides), - with 0, A with 1, C with 2, G with 3 and T with 4 in " + prefix + ".inp (the main PHASE input file).\n");
        }
        if(result.hasKnownFile()) {
            var fout = File.write(prefix + ".known", false);
            fout.writeString(result.getKnownFile());
            fout.close();
            Sys.stderr().writeString("A known phase file (" + prefix + ".known) has also been generated to tell PHASE which phases are already known and which ones are to infer.\n");
        }
        if(result.hasConstFile()) {
            var fout = File.write(prefix + ".const", false);
            fout.writeString(result.getConstFile());
            fout.close();
            Sys.stderr().writeString("In order to reduce PHASE running time, constant positions have been removed from the dataset. These constant positions have been stored in " + prefix + ".const interspersed with periods (.) representing variable positions.\n");
        }

        if(result.hasSuggestedCommand()) {
            Sys.stderr().writeString("Suggested command syntax (PHASE v2.1):\n\n");
            var r:String = result.getSuggestedPhaseCommand();
            r = r.split("seqphase").join(prefix);
            Sys.stderr().writeString(r);
            Sys.stderr().writeString("\n\n");
            Sys.stderr().writeString("(the result of the analysis will be stored in a series of files with names starting with '" + prefix + ".out').\n");
        }
        Sys.stderr().writeString("\n");
        #end
    }

}

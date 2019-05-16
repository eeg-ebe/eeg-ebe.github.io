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

import haxe.ds.StringMap;
import haxe.ds.ArraySort;

/**
 * This class principally contains the content of SeqPhase1.pl. Since Haxe expects you to have classes
 * but the original python script doesn't contain any, there are some changes in structure and code
 * ordering. These changes are also needed because the code needs to get converted into JavaScript code
 * later on and reading / storing files works asynchronly in JavaScript (which is quite different to the
 * reading mechanisms of Perl).
 */
class FastaAlignmentParser {

    private static var authorizedCharacters:StringMap<Bool> = [
        'A' => true, 'T' => true, 'G' => true, 'C' => true, 'N' => true, '-' => true, '?' => true,
        'R' => false, 'Y' => false, 'M' => false, 'K' => false, 'W' => false, 'S' => false
    ];

    private var fastaContent:Array<Entry>;
    private var seqLength:Int;

    public function new(fileContent:Null<String>, allChecks:Bool, allSort:Bool, fileNr:Int) {
        fastaContent = new Array<Entry>();
        seqLength = -1;
        // checks
        if (fileContent == null) return;
        if (stripString(fileContent) == "") {
            SeqPhase1Result.instance().addErr("Empty file!", fileNr);
            return;
        }
        if (!startsWith(fileContent, ">") && !startsWith(fileContent, ";")) {
            SeqPhase1Result.instance().addErr("File does not seem to be a fasta file!", fileNr);
            return;
        }
        // parse data
        var lines:Array<String> = fileContent.split("\n");
        if (lines.length == 0) {
            SeqPhase1Result.instance().addErr("Not a fasta but an empty file!", fileNr);
            return;
        } else if(lines.length == 1) {
            SeqPhase1Result.instance().addErr("Only 1 line detected! Please check data format (opening the alignment in MEGA (http://www.megasoftware.net/) and exporting it as FASTA again may solve the problem; alternatively, there may be a problem with end-of-line characters - see http://en.wikipedia.org/wiki/Newline for details!", fileNr);
            return;
        }
        var entryMap:StringMap<Entry> = new StringMap<Entry>();
        var current:Null<Entry> = null;
        var lineNo:Int = 0;
        for (line in lines) {
            lineNo++;
            line = stripString(line);
            if (startsWith(line, ";")) { // comment
                continue;
            } else if (startsWith(line, ">")) { // header
                var indName:String = stripString(line.substr(1));
                if(entryMap.exists(indName)) {
                    SeqPhase1Result.instance().addErr("Repeat of name " + indName
                        + " encountered in alignment (line " +  lineNo + ", line "
                        + entryMap.get(indName).getLineNo() + ")", fileNr);
                }
                current = new Entry(lineNo, indName);
                entryMap.set(indName, current);
                if(indName.length == 0) {
                    SeqPhase1Result.instance().addErr("Missing sequence name, line " + lineNo, fileNr);
                }
            } else {
                for(i in 0...line.length) {
                    var char:String = line.charAt(i);
                    if(!authorizedCharacters.exists(char)) {
                        SeqPhase1Result.instance().addErr("Unknown character state " + char + " in "
                        + current.getName() + ", line " + lineNo, fileNr);
                    } else if(allChecks && authorizedCharacters.get(char) == false) {
                        SeqPhase1Result.instance().addErr("Unallowed state " + char + " in "
                        + current.getName() + ", line " + lineNo, fileNr);
                    }
                }
                line = (line.split("?")).join("N");
                current.addToSeq(line.toUpperCase());
            }
        }
        if(current == null) {
            SeqPhase1Result.instance().addErr("Corrupted Fasta File", fileNr);
            return;
        }
        if (current.getSeq() == "") {
            SeqPhase1Result.instance().addErr("Empty sequence " + current.getName() + ", line " + current.getLineNo(), fileNr);
            return;
        }
        // sanity checks
        seqLength = current.getSeq().length;
        for(key in entryMap.keys()) {
            var val:Entry = entryMap.get(key);
            fastaContent.push(val);
            if(val.getSeq().length != current.getSeq().length) {
                SeqPhase1Result.instance().addErr("Not all sequences in this file have equal lengths. E.g. sequence "
                + val.getName() + " (line " + val.getLineNo() + ") is of length " + val.getSeq().length
                + " while sequence " + current.getName() + " (line " + current.getLineNo()
                + ") is of length " + val.getSeq().length, fileNr);
                return;
            }
            if (startsWith(val.getSeq(), "-")) {
                SeqPhase1Result.instance().addWrn("Sequence " + val.getName() + " (line " + val.getLineNo()
                + ") starts with '-'. Is it a real indel or did you mean 'N' or '?' (missing data)?", fileNr);
            }
            if (val.getSeq().charAt(val.getSeq().length - 1) == "-") {
                SeqPhase1Result.instance().addWrn("Sequence " + val.getName() + " (line " + val.getLineNo()
                + ") ends with '-'. Is it a real indel or did you mean 'N' or '?' (missing data)?", fileNr);
            }
        }
        // sort
        fastaContent.sort(function(e1:Entry, e2:Entry) {
            if(allSort) {
                var nameE1:String = e1.getName();
                var nameE2:String = e1.getName();
                var aNameE1:String = nameE1.substring(0, nameE1.length - 1);
                var aNameE2:String = nameE2.substring(0, nameE2.length - 1);
                if(aNameE1 < aNameE2) return -1;
                if(aNameE1 > aNameE2) return 1;
                var lNameE1:String = nameE1.charAt(nameE1.length - 1);
                var lNameE2:String = nameE2.charAt(nameE2.length - 1);
                if(lNameE1 < lNameE2) return -1;
                if(lNameE1 > lNameE2) return 1;
                return 0;
            } else {
                if(e1.getName() < e2.getName()) return -1;
                if(e1.getName() > e2.getName()) return 1;
                return 0;
            }
        });
        if(allChecks) {
            if (fastaContent.length % 2 != 0) {
                SeqPhase1Result.instance().addErr("Uneven number of sequences in alignment: please check data.", fileNr);
            }
            var lastName:Null<String> = null;
            for(entry in fastaContent) {
                if(lastName == null) {
                    lastName = entry.getName();
                    lastName = lastName.substring(0, lastName.length - 1);
                } else {
                    var curName:String = entry.getName();
                    curName = curName.substring(0, curName.length - 1);
                    if(lastName != curName) {
                        SeqPhase1Result.instance().addErr("Only one haplotype sequence found for individual " + entry.getName(), fileNr);
                    } else {
                        lastName = null;
                    }
                }
            }
        }
    }

    public function getSeqLength():Int {
        return seqLength;
    }

    public function getSequences():Array<Entry> {
        return fastaContent;
    }

    // Helper functions
    public static inline function startsWith(t:String,s:String):Bool {
        return t.substr(0, s.length) == s;
    }
    public static inline function isWhitespace(s:String, pos:Int):Bool {
        var cCode:Int = s.charCodeAt(pos);
        var result:Bool = false;
        for(ele in [9,10,11,12,13,32,133,160,5760,8192,8192,8193,8194,8195,8196,8197,8198,8199,8200,8201,8202,8232,8233,8239,8287,12288,6158,8203,8204,8205,8288,65279]) {
            if(ele == cCode) {
                result = true;
                break;
            }
        }
        return result;
    }
    public static inline function stripStringBegin(s:String):String {
        var begin:Int = 0;
        var sLen:Int = s.length;
        while(begin < sLen && isWhitespace(s, begin)) {
            begin++;
        }
        return s.substr(begin);
    }
    public static inline function stripStringEnd(s:String):String {
        var end:Int = s.length;
        while(end > 0 && isWhitespace(s, end-1)) {
            end--;
        }
        return s.substring(0, end);
    }
    public static inline function stripString(s:String):String {
        return stripStringBegin(stripStringEnd(s));
    }
}

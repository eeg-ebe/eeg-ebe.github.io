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

import haxe.ds.ListSort;

/**
 * Since Haxe expects you to have classes but the original perl script doesn't contain any, there are
 * some changes in structure and code ordering. These changes are also needed because the code needs to
 * get converted into JavaScript code later on and reading / storing files works asynchronly in JavaScript
 * (which is quite different to the reading mechanisms of Perl).
 */
class Individual {

    private var name:String;
    private var seq1:String;
    private var seq2:String;
    private var index:Int;
    private var p:Float;

    public function new(name:String, seq1:String, seq2:String, index:Int, p:Float) {
        this.name = name;
        this.seq1 = seq1;
        this.seq2 = seq2;
        this.index = index;
        this.p = p;
    }

    public function getName():String {
        return name;
    }
    public function getSequence1():String {
        return seq1;
    }
    public function getSequence2():String {
        return seq2;
    }
    public function getIndex():Int {
        return index;
    }
    public function getProbability():Float {
        return p;
    }

    public function isHomozygous():Bool {
        return seq1 == seq2;
    }
    public function isHeterozygous():Bool {
        return seq1 != seq2;
    }

// out
//name . a
// out_pairs
//r: t=1 name . a
//r: t!1 name-counter . a (t)
//!r: name . a_counter(t)

// This is horrible, but JFF don't wanted to the same output style everytime!!!
// Changed nevertheless, if he complains -> uncomment the rest of the code
    public function getFasta(reduce:Bool, outFile:Bool):String {
        var result:List<String> = new List<String>();
//        if (outFile) {
//            if (isHomozygous() && reduce) {
//                result.add(">" + name);
//                result.add(seq1);
//            } else {
//                result.add(">" + name + "a");
//                result.add(seq1);
//                result.add(">" + name + "b");
//                result.add(seq2);
//            }
//        } else {
//            if (reduce) {
                if (p == 1.0) {
                    if (isHomozygous()) {
                        result.add(">" + name);
                        result.add(seq1);
                    } else {
                        result.add(">" + name + "a");
                        result.add(seq1);
                        result.add(">" + name + "b");
                        result.add(seq2);
                    }
                } else { // name-counter . a (t)
                    if (isHomozygous()) {
                        result.add(">" + name + "-" + index + "(" + p + ")");
                        result.add(seq1);
                    } else {
                        result.add(">" + name + "-" + index + "a(" + p + ")");
                        result.add(seq1);
                        result.add(">" + name + "-" + index + "b(" + p + ")");
                        result.add(seq2);
                    }
                }
//            } else {
//                result.add(">" + name + "a_" + index + "(" + p + ")");
//                result.add(seq1);
//                result.add(">" + name + "b_" + index + "(" + p + ")");
//                result.add(seq2);
//            }
//        }
        return result.join("\n");
    }

}

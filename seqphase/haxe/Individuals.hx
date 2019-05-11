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

/**
 * Translation of seqphase1, seqphase2 into haxe code.
 *
 * Since Haxe expects you to have classes but the original perl script doesn't contain any, there are
 * some changes in structure and code ordering. These changes are also needed because the code needs to
 * get converted into JavaScript code later on and reading / storing files works asynchronly in JavaScript
 * (which is quite different to the reading mechanisms of Perl).
 */
class Individuals {

    private var inds:Array<Individual>;
    private var outFile:Bool;

    public function new() {
        inds = new Array<Individual>();
    }

    public function addIndividual(ind:Individual):Void {
        inds.push(ind);
    }
    public function setOutFile(b:Bool):Void {
        outFile = b;
    }

    public function getFasta(reduce:Bool, sort:Bool):String {
        var result:List<String> = new List<String>();
        inds.sort(function(i1:Individual, i2:Individual) {
            if(i1.getName() < i2.getName()) return -1;
            if(i1.getName() > i2.getName()) return 1;
            return i1.getIndex() - i2.getIndex();
        });
        for (ind in inds) {
            result.add(ind.getFasta(reduce, outFile));
        }
        return result.join("\n");
    }

}

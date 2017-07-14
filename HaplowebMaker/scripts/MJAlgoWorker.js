self.importScripts("MJAlgo.js");

Printer = function () {
    this.indent = "  ";
    this.newline = "\n";
    this.countingOffset = 1;
    this.l = [];
    this.printString = function (s) {
        this.l.push(s);
    };
    this.close = function () {};
    this.toText = function () {
        return this.l.join("");
    }
}

self.addEventListener('message', function(e) {
    var m = new mj_MJAlgo();
    for(var i = 0; i < e.data["seqs"].length; i++) {
        var seq = e.data["seqs"][i];
        m.addSequence(seq["name"], seq["seq"]);
    }
    m.finishedAddingSequences();
    m.runMJ(e.data["epsilon"]);
    var p = new Printer();
    m.finalizeNetwork().printTxt(p);
    self.postMessage(p.toText());
}, false);

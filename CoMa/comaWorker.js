self.importScripts("../HaplowebMaker/scripts/coma.js");

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
    var comaData = CoMa.parsePartitionFile(e.data);
    var p = new Printer();
    var p2 = new Printer();
    CoMa.runComaFromPartition(comaData, p, p2);
    var comaTxt = p.toText();
    var comaLstTxt = p2.toText();
    self.postMessage(comaTxt);
});

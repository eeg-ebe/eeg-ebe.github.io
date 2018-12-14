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
    var txt = e.data['txt'];
    var strategy = e.data['distanceCalcStrategy'];
    var comaData = CoMa.parsePartitionFile(txt);
    var p = new Printer();
    var p2 = new Printer();
    CoMa.runComaFromPartition(comaData, p, p2, strategy);
    var comaTxt = p.toText();
    var comaLstTxt = p2.toText();
    var result = {};
    result['svg'] = comaTxt;
    result['lst'] = comaLstTxt;
    result['html'] = comaTxt + "<br><br><br><pre>" + comaLstTxt + "</pre>";
    self.postMessage(result);
});

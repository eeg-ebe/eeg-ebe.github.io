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
    var project = e.data;
    // create first data in project
    self.postMessage([
        {
            "key" : ["progress"],
            "val" : 0
        }
    ]);
    for(var i = 0; i < e.data["seqs"].length; i++) {
        
    }
        {
            "key" : ["faFiles", 0, "status"],
            "val" : "running.label"
        },
        {
            "key" : ["faFiles", 0, "filename"],
            "val" : "yeah"
        },
        {
            "key" : ["calculationEndDate"],
            "val" : Date.now()
        }
    ]);
/*
    var m = new mj_MJAlgo();
    for(var i = 0; i < e.data["seqs"].length; i++) {
        var seq = e.data["seqs"][i];
        m.addSequence(seq["name"], seq["seq"]);
    }
    m.finishedAddingSequences();
    m.runMJ(e.data["epsilon"]);
    var p = new Printer();
    m.finalizeNetwork().printTxt(p);
    self.postMessage(project);
*/
}, false);
